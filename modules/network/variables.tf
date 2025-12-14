variable "name" {
  description = "Name/prefix for networking resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "Availability zones to use."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (one per AZ)."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.public_subnet_cidrs) == 0 || length(var.public_subnet_cidrs) == length(var.azs)
    error_message = "If public_subnet_cidrs is set, it must have the same number of elements as azs (or be left empty to auto-calculate)."
  }
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (one per AZ)."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.private_subnet_cidrs) == 0 || length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "If private_subnet_cidrs is set, it must have the same number of elements as azs (or be left empty to auto-calculate)."
  }
}

variable "subnet_newbits" {
  description = "When subnet CIDRs are not provided, how many additional bits to add to vpc_cidr when carving subnets (cidrsubnet newbits). Example: /16 + 8 -> /24 subnets."
  type        = number
  default     = 8
}

variable "public_subnet_offset" {
  description = "When subnet CIDRs are not provided, the starting netnum offset for public subnets."
  type        = number
  default     = 0
}

variable "private_subnet_offset" {
  description = "When subnet CIDRs are not provided, the starting netnum offset for private subnets."
  type        = number
  default     = 100
}

variable "single_nat" {
  description = "If true, create a single NAT Gateway for all private subnets."
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Whether instances launched in public subnets should receive a public IP."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to networking resources."
  type        = map(string)
  default     = {}
}


