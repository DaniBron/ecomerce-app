# Define a network policy that allows only traffic from frontend pods to backend pods
resource "kubernetes_network_policy" "allow_frontend_to_backend" {
  metadata {
    name      = "allow-frontend-to-backend"
    namespace = "ecommerce-app"
  }

  spec {
    pod_selector {
      match_labels = {
        role = "backend"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            role = "frontend"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

# Define a network policy that denies all external traffic to the database pods except from backend pods
resource "kubernetes_network_policy" "deny_external_to_db" {
  metadata {
    name      = "deny-external-to-db"
    namespace = "ecommerce-app"
  }

  spec {
    pod_selector {
      match_labels = {
        role = "database"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            role = "backend"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}
