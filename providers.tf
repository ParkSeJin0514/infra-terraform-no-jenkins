# ============================================================================
# providers.tf - Provider 설정
# ============================================================================
# Terraform이 AWS, Kubernetes, Helm 리소스를 관리하기 위한 Provider 설정
# ============================================================================

# ============================================================================
# AWS Provider
# ============================================================================
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Managed = "terraform"
    }
  }
}

# ============================================================================
# Kubernetes Provider
# ============================================================================
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# ============================================================================
# Helm Provider
# ============================================================================
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
    }
  }
}

# ============================================================================
# 🆕 Kubectl Provider
# ============================================================================
# kubernetes_manifest 대신 kubectl_manifest 사용을 위한 Provider
# 장점: Plan 단계에서 K8s API 연결이 필요 없음 (EKS 생성 전에도 Plan 가능)
# 용도: ArgoCD Application CRD 등 Custom Resource 배포
# ============================================================================
provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }

  load_config_file = false
}