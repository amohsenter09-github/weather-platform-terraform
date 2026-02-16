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
