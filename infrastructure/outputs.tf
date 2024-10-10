output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = aws_db_instance.ecommerce_db.endpoint
}

output "s3_bucket_name" {
  value = aws_s3_bucket.ecommerce_bucket.bucket
}

output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.ecommerce_search.endpoint
}

