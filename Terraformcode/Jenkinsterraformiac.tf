provider "aws" {
  region = "us-west-2"
}

# Create EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "jenkins-eks-cluster-awstrainingwithjagan"
  cluster_version = "1.21"
  subnets         = ["subnet-12345678", "subnet-87654321"]
  vpc_id          = "vpc-12345678"

  node_groups = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 1

      instance_type = "t3.medium"
    }
  }
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.eks_auth.token

  load_config_file       = false
}

data "aws_eks_cluster_auth" "eks_auth" {
  name = module.eks.cluster_id
}

# Create Namespace for Jenkins
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

# Jenkins Deployment
resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins-server"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {
        container {
          name  = "jenkins"
          image = "jenkins/jenkins:lts"

          port {
            container_port = 8080
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# Jenkins Service - Exposing with LoadBalancer
resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins-service"
    namespace = kubernetes_namespace.jenkins.metadata[0].name
  }

  spec {
    selector = {
      app = "jenkins"
    }

    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}