resource "helm_release" "ecommerce_app" {
  name       = "ecommerce-app"
  chart      = "./ecommerce-app-0.1.0.tgz"  # Local path to your Helm chart
  namespace  = "default"  # Ensure this matches the namespace where you want to install

  # Specify values to customize the chart
  set {
    name  = "SQLALCHEMY_DATABASE_URI"
    value = "mysql+pymysql://admin:strong-password@terraform-2024101311021804300000000a.cffg3k7ox7tp.us-east-1.rds.amazonaws.com:3306/ecommercedb"
  }

  set {
    name  = "ELASTICSEARCH_URL"
    value = "search-ecommerce-search-qpi56ysu2iyx3wfgjgyvqaeafi.us-east-1.es.amazonaws.com"
  }

  # Add more environment variables or Helm chart values as needed
}
