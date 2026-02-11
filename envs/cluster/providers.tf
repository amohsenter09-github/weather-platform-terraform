terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # NOTE: This repo uses terraform-aws-modules/eks, which currently expects
      # aws_launch_template schema compatible with AWS provider v5.x.
      version = ">= 5.0, < 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.cluster_name,
      "--region",
      "eu-west-1",
      "--output",
      "json",
    ]
  }
}

provider "helm" {
  # Avoid relying on local user Helm cache under ~/Library/Caches/helm.
  # Keep everything self-contained inside this env folder.
  repository_config_path = "${path.module}/.helm/repositories.yaml"
  # Helm expects index files under a "repository" cache dir (e.g. .../helm/repository/<repo>-index.yaml)
  repository_cache = "${path.module}/.helm/repository"

  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.cluster_name,
        "--region",
        "eu-west-1",
        "--output",
        "json",
      ]
    }
  }
}


