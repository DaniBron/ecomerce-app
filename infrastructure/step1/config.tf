provider "kubernetes" {
  config_path    = "C:/Users/User/.kube/config"  # This should point to your kubeconfig file
  config_context = "arn:aws:eks:us-east-1:049088564626:cluster/ecommerce-cluster"  # EKS cluster context
}

resource "kubernetes_namespace" "ecommerce_app" {
  metadata {
    name = "ecommerce-app"
  }
}
