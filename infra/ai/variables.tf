variable "aws_region" {
  description = "AWS region for AI/MLOps resources."
  type        = string
  default     = "eu-west-1"
}

variable "tags" {
  description = "Additional tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# Experimental toggles – set to true when module is implemented
variable "enable_event_bus" {
  type    = bool
  default = false
}

variable "enable_observability" {
  type    = bool
  default = false
}

variable "enable_sagemaker" {
  type    = bool
  default = false
}

variable "enable_vector_db" {
  type    = bool
  default = false
}

variable "enable_llm_gateway" {
  type    = bool
  default = false
}

variable "enable_agentic_memory" {
  type    = bool
  default = false
}

variable "enable_data_engineering" {
  type    = bool
  default = false
}
