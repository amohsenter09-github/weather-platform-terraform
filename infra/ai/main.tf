# AI/MLOps infrastructure – experimental scaffold
# Enable modules by setting count = 1 when ready to implement

locals {
  project = "platform"
  stack   = "ai"
  tags    = merge(var.tags, { Project = local.project, Stack = local.stack, ManagedBy = "Terraform" })
}

# 1. MLOps Foundations
module "mlops_foundation" {
  source = "../../modules/mlops_foundation"
  tags   = local.tags
}

module "mlops_event_bus" {
  count  = var.enable_event_bus ? 1 : 0
  source = "../../modules/mlops_event_bus"
  tags   = local.tags
}

module "mlops_observability" {
  count  = var.enable_observability ? 1 : 0
  source = "../../modules/mlops_observability"
  tags   = local.tags
}

# 2. MLOps on Cloud (SageMaker)
module "mlops_sagemaker" {
  count  = var.enable_sagemaker ? 1 : 0
  source = "../../modules/mlops_sagemaker"
  tags   = local.tags
}

# 3. LLMOps (Vector DB + gateway)
module "mlops_vector_db" {
  count  = var.enable_vector_db ? 1 : 0
  source = "../../modules/mlops_vector_db"
  tags   = local.tags
}

module "mlops_llm_gateway" {
  count  = var.enable_llm_gateway ? 1 : 0
  source = "../../modules/mlops_llm_gateway"
  tags   = local.tags
}

# 4. Agentic AI Ops
module "agentic_memory" {
  count  = var.enable_agentic_memory ? 1 : 0
  source = "../../modules/agentic_memory"
  tags   = local.tags
}

# 5. Data Engineering
module "data_engineering" {
  count  = var.enable_data_engineering ? 1 : 0
  source = "../../modules/data_engineering"
  tags   = local.tags
}
