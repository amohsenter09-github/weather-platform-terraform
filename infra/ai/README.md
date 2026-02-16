# AI/MLOps Infrastructure (Experimental Scaffold)

Terraform stack for AI/ML workloads. **No resources are created by default** – modules are placeholders. Enable via variables when implementing.

## Layout

| Module | Purpose | Variable |
|--------|---------|----------|
| mlops_foundation | S3 (raw/processed/features/artifacts) + IAM/IRSA | always on |
| mlops_event_bus | Kinesis/MSK/SQS | `enable_event_bus` |
| mlops_observability | Metrics, tracing, logging | `enable_observability` |
| mlops_sagemaker | SageMaker domain, pipelines, model registry | `enable_sagemaker` |
| mlops_vector_db | Aurora pgvector / OpenSearch | `enable_vector_db` |
| mlops_llm_gateway | API gateway, KMS, secrets for LLM | `enable_llm_gateway` |
| agentic_memory | Redis/RDS for agent state | `enable_agentic_memory` |
| data_engineering | Kinesis, S3 lake, Glue | `enable_data_engineering` |

## Helm (Argo CD)

| Path | Purpose |
|------|---------|
| helm/argo-workflows/ | ML pipeline orchestration |
| helm/kserve/ | Model serving (InferenceService) |
| helm/kyverno/ | Policy engine (existing) |

## App Repo (weather-api-fastapi)

Create workloads with overlays dev/uat/prod:

- `mlops/batch-trainer`
- `mlops/realtime-inference`
- `llm/rag-api`
- `llm/embedding-worker`

## Implementation Order

1. **mlops_foundation** – S3 + IRSA (Step 1)
2. **Argo Workflows + KServe** – batch + realtime (Step 2–3)
3. **mlops_vector_db** – RAG (Step 5)
4. **DevSecOps** – Kyverno policies for ML (Step 7)
