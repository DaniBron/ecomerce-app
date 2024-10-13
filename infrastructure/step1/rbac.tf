# Define an admin role for Kubernetes service accounts within the "ecommerce-app" namespace
resource "kubernetes_role" "ecommerce_admin" {
  metadata {
    name      = "ecommerce-admin"
    namespace = "ecommerce-app"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "deployments", "secrets"]
    verbs      = ["create", "delete", "get", "list", "update", "patch", "watch"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["create", "delete", "get", "list", "update", "patch", "watch"]
  }
}

# Bind the admin role to the service account for ecommerce-app
resource "kubernetes_role_binding" "ecommerce_admin_binding" {
  metadata {
    name      = "ecommerce-admin-binding"
    namespace = "ecommerce-app"
  }

  role_ref {
    kind     = "Role"
    name     = kubernetes_role.ecommerce_admin.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind     = "ServiceAccount"
    name     = "ecommerce-sa"
    namespace = "ecommerce-app"
  }
}

# Define a limited role for services that only need to read from Kubernetes resources
resource "kubernetes_role" "ecommerce_reader" {
  metadata {
    name      = "ecommerce-reader"
    namespace = "ecommerce-app"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

# Bind the reader role to a different service account for read-only access
resource "kubernetes_role_binding" "ecommerce_reader_binding" {
  metadata {
    name      = "ecommerce-reader-binding"
    namespace = "ecommerce-app"
  }

  role_ref {
    kind     = "Role"
    name     = kubernetes_role.ecommerce_reader.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }

  subject {
    kind     = "ServiceAccount"
    name     = "ecommerce-reader-sa"
    namespace = "ecommerce-app"
  }
}
