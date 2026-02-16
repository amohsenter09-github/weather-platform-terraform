# MLOps Platform – Flow Diagram

## 1. Repos and Deploy Flow

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          DEPLOYMENT FLOW                                          │
└─────────────────────────────────────────────────────────────────────────────────┘

  weather-platform-terraform                    weather-api-fastapi
  (Infra Repo)                                  (App / GitOps Repo)
         │                                              │
         │  terraform apply                              │  git push
         ▼                                              ▼
  ┌──────────────────┐                         ┌──────────────────┐
  │  AWS (Terraform)  │                         │   Git (source)    │
  │  • EKS clusters  │                         │  • Kustomize      │
  │  • S3, IAM, IRSA │                         │  • overlays       │
  │  • VPC, ECR, ACM │                         │  • manifests      │
  └────────┬─────────┘                         └────────┬─────────┘
           │                                             │
           │  kubeconfig                                 │
           ▼                                             │
  ┌──────────────────┐                                   │
  │  Helm (manual)    │  kubectl apply -f helm/           │
  │  • Argo CD       │◄──────────────────────────────────┤
  │  • Kyverno apps  │                                   │
  └────────┬─────────┘                                   │
           │                                             │
           │  Argo CD watches Git                         │
           ▼                                             ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │                     Argo CD (hub cluster)                          │
  │  • Syncs Applications from Git                                    │
  │  • Deploys to hub + dev + prod + uat clusters                      │
  └────────┬─────────────────────────────────────────────────────────┘
           │
           │  deploys workloads
           ▼
  ┌──────────────────────────────────────────────────────────────────┐
  │              EKS Clusters (hub, dev, prod, uat)                   │
  │  • Weather API, Air Quality API                                    │
  │  • batch-trainer, realtime-inference, rag-api (future)             │
  └──────────────────────────────────────────────────────────────────┘
```

---

## 2. Terraform Modules (Infra Repo)

```
                    infra/ai (main.tf)
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ mlops_foundation │   │ mlops_event_bus │   │ mlops_observability │
│ S3, IAM, IRSA │   │ Kinesis/MSK/SQS│   │ Metrics, tracing   │
└───────┬───────┘   └───────┬───────┘   └────────┬──────┘
        │                   │                   │
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│ mlops_sagemaker │   │ mlops_vector_db │   │ mlops_llm_gateway │
│ Domain, pipelines│   │ pgvector/OpenSearch│   │ KMS, API gateway  │
└───────┬───────┘   └───────┬───────┘   └────────┬──────┘
        │                   │                   │
        │                   │                   │
        ▼                   ▼                   ▼
┌───────────────┐   ┌───────────────┐
│ agentic_memory │   │ data_engineering │
│ Redis, RDS     │   │ Kinesis, Glue   │
└───────────────┘   └───────────────┘
```

---

## 3. Data Flow (ML Pipelines)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        BATCH TRAINING PIPELINE                                    │
└─────────────────────────────────────────────────────────────────────────────────┘

   Weather API          S3 (raw)        Argo Workflow         S3 (artifacts)
   (or external)  ────►  bucket   ────►  / CronJob   ────►   model.joblib
        │                    │                │                     │
        │                    │                │                     │
        │                    ▼                ▼                     │
        │              ┌──────────┐    ┌──────────────┐            │
        │              │ Features │    │ batch-trainer│            │
        │              │ (S3)     │◄───│ Pod (IRSA)   │────────────┘
        │              └────┬─────┘    └──────────────┘
        │                   │
        └───────────────────┘
```

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        REALTIME INFERENCE                                        │
└─────────────────────────────────────────────────────────────────────────────────┘

   S3 (artifacts)        KServe / BentoML         Ingress / ALB          Client
   model.joblib   ────►  InferenceService  ────►  HTTPS endpoint  ────►  HTTP
        │                      │                          │
        │                      │                          │
        │                      ▼                          ▼
        │               ┌─────────────┐            realtime-inference
        └──────────────►│ Load model  │                   API
                       │ from S3     │
                       └─────────────┘
```

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        RAG / LLMOps                                               │
└─────────────────────────────────────────────────────────────────────────────────┘

   Documents          embedding-worker         Vector DB              rag-api
   (S3 or API)  ────►  (embeddings)     ────►  pgvector/OpenSearch ────►  Client
        │                    │                       │                      │
        │                    │                       │  query              │
        │                    ▼                       │  retrieve            │
        │              ┌─────────────┐              │  LLM                 │
        │              │ Vector store│◄─────────────┘                      │
        │              │ (embeddings)│                                       │
        │              └─────────────┘                                       │
        │                                                                   ▼
        └─────────────────────────────────────────────────────────  RAG response
```

---

## 4. Cluster Topology

```
                              ┌─────────────────┐
                              │   Hub (eu-w-2)   │
                              │   • Argo CD      │
                              │   • Kyverno      │
                              └────────┬────────┘
                                        │
              ┌─────────────────────────┼─────────────────────────┐
              │                         │                         │
              ▼                         ▼                         ▼
     ┌────────────────┐        ┌────────────────┐        ┌────────────────┐
     │  Dev (eu-w-1)   │        │  UAT (eu-w-1)   │        │ Prod (eu-w-1)   │
     │  • Weather API  │        │  • Weather API  │        │  • Weather API  │
     │  • batch-train │        │  • staging      │        │  • production    │
     │  • KServe      │        │                │        │  • KServe        │
     └────────────────┘        └────────────────┘        └────────────────┘
              │                         │                         │
              └────────────────────────┼─────────────────────────┘
                                        │
                                        ▼
                              ┌─────────────────┐
                              │  Shared Infra    │
                              │  • S3 buckets    │
                              │  • IAM / IRSA    │
                              │  (per env)       │
                              └─────────────────┘
```

---

## 5. Implementation Order (Arrows = Dependencies)

```
  Step 1              Step 2              Step 3              Step 4
  mlops_foundation ──► Argo Workflows ──► KServe ──► Orchestration
  (S3 + IRSA)         (pipelines)        (inference)  (full pipeline)
       │                    │                  │
       │                    │                  │
       ▼                    ▼                  ▼
  Step 5              Step 6              Step 7
  LLMOps              Agentic Ops         DevSecOps
  (vector DB,          (memory,            (Kyverno,
   RAG)                 tools)              scanning)
```

---

## 6. Who Feeds the MLOps Flow (From Data to Trained Model)

Step-by-step: **who** or **what** provides input at each stage until the model is trained.

| # | Step | Who/What Feeds It | What Happens |
|---|------|-------------------|--------------|
| **1** | **Raw data** | **Weather API** or **Air Quality API** – live APIs that your platform already runs. Or: external data source (CSV upload, partner API, IoT). | Data scientist or engineer defines the source. For weather use case: call `/forecast` or historical endpoints, export to JSON/Parquet. |
| **2** | **Data ingestion** | **CronJob** or **Argo Workflow** (scheduled) – runs daily/hourly. Or: **manual script** during development. | A small job fetches from Weather API and writes to S3 `raw/` bucket. IRSA lets the pod access S3. |
| **3** | **Raw storage** | **S3 raw bucket** (mlops_foundation) – receives the fetched data. | Files land as `s3://bucket/raw/date=2025-02-06/weather.json`. |
| **4** | **Feature engineering** | **Argo Workflow** or **Kubernetes Job** – runs after ingestion or on schedule. | Reads from S3 raw, computes features (e.g. rolling averages, lags), writes to S3 `features/`. |
| **5** | **Features storage** | **S3 features bucket** – stores feature tables. | Output: `s3://bucket/features/train.parquet`, `test.parquet`. |
| **6** | **Training trigger** | **Argo CronWorkflow** (e.g. weekly) or **manual run** via Argo UI/CLI. Or: **event** (SQS message when new data arrives). | Something kicks off the training pipeline. |
| **7** | **Training job** | **batch-trainer** (Kubernetes Job / Argo Workflow step) – runs on EKS. | Pod uses IRSA to read S3 features, train scikit-learn model, write to S3 `artifacts/`. |
| **8** | **Model artifact** | **S3 artifacts bucket** – stores `model.joblib` (or equivalent). | `s3://bucket/artifacts/weather-model/v1/model.joblib`. |
| **9** | **Model registry** (optional) | **MLflow** or **SageMaker Model Registry** – tracks versions. | Model is registered with metadata (metrics, timestamp). |
| **10** | **Inference deployment** | **KServe** or **BentoML** – loads model from S3, serves HTTP. | realtime-inference service fetches model.joblib and serves predictions. |

### Summary flow

```
  [1] Weather API ──► [2] CronJob ──► [3] S3 raw ──► [4] Feature Job ──► [5] S3 features
                                                                              │
                                                                              ▼
  [10] Inference ◄── [9] Registry ◄── [8] S3 artifacts ◄── [7] batch-trainer ◄─┘
       (KServe)         (optional)         model.joblib      [6] Trigger
```

---

## 7. Step-by-Step: How `http://&lt;alb&gt;/weather?city=Berlin` Becomes a Model

There are **two different flows**. Only one leads to S3 and training.

### Path A: Real-time (user request) – **does NOT go to S3**

| Step | What happens |
|------|--------------|
| 1 | You call `http://<alb-hostname>/weather?city=Berlin` in a browser or with curl. |
| 2 | ALB forwards the request to the Weather API pod. |
| 3 | Weather API returns JSON, e.g. `{"city":"Berlin","temp":12,...}`. |
| 4 | You receive that JSON. **End of flow.** Nothing is written to S3. |

---

### Path B: Batch collection for ML – **this writes to S3**

This is a separate process that runs **on a schedule**, not when you hit the API yourself.

| Step | Who/What | What happens |
|------|----------|--------------|
| **1** | **Data ingestion CronJob** | A Kubernetes CronJob runs every hour (or day). It is a pod that executes a script. |
| **2** | **Script inside the CronJob** | The script calls the Weather API internally, e.g. `GET http://weather-api/weather?city=Berlin` (from inside the cluster). It gets the same JSON you would get. |
| **3** | **Script writes to S3** | The script saves that JSON to the S3 raw bucket: `s3://platform-mlops-raw/raw/date=2025-02-06/berlin.json`. |
| **4** | **S3 raw bucket** | Now the data is stored. Multiple runs over days = many JSON files. |
| **5** | **Feature Job** | Another job (CronJob or Argo Workflow) runs. It reads all JSON files from S3 raw, computes features (e.g. rolling averages), and writes to S3 features: `s3://.../features/train.parquet`. |
| **6** | **Training trigger** | A schedule (e.g. weekly) or manual trigger starts the training pipeline. |
| **7** | **batch-trainer** | A Kubernetes Job runs. It reads S3 features, trains a scikit-learn model, and saves to S3 artifacts: `s3://.../artifacts/model.joblib`. |
| **8** | **Inference** | KServe loads `model.joblib` from S3 and serves predictions via HTTP. |

### Visual: Two paths side by side

```
PATH A (Real-time – no S3)              PATH B (Batch – for ML training)
─────────────────────────               ────────────────────────────────

  You (browser)                              CronJob pod (runs hourly)
       │                                            │
       │  GET /weather?city=Berlin                   │  GET /weather?city=Berlin
       ▼                                            ▼
  Weather API ◄────────────────────────────── Weather API
       │                                            │
       │  JSON response                             │  JSON response
       ▼                                            ▼
  You receive JSON                            Script writes to S3
  (done)                                            │
                                                    ▼
                                              s3://.../raw/berlin.json
                                                    │
                                                    ▼
                                              Feature Job → S3 features
                                                    │
                                                    ▼
                                              batch-trainer → S3 artifacts
                                                    │
                                                    ▼
                                              model.joblib
```

### Summary

- **Path A**: Your API call → JSON back. No S3, no training.
- **Path B**: A CronJob calls the API and saves responses to S3. Those stored files are what training uses. The CronJob is the “feeder” that copies API data into S3.
