# Output for the EKS cluster name
output "eks_cluster_name" {
  value = module.eks.cluster_name
}

# Output for the RDS endpoint
output "rds_endpoint" {
  value = aws_db_instance.ecommerce_db.endpoint
}

# Output for the S3 bucket name
output "s3_bucket_name" {
  value = aws_s3_bucket.ecommerce_bucket.bucket
}

# Output for the Elasticsearch endpoint
output "elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.ecommerce_search.endpoint
}

# Output for the EKS cluster API endpoint
output "cluster_endpoint" {
  description = "The endpoint for the EKS Kubernetes API."
  value       = module.eks.cluster_endpoint
}

# Output for the EKS cluster certificate authority data
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

# Output for the EKS cluster ID
output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.eks.cluster_id
}

# Output for the Kinesis stream ARN
output "kinesis_stream_arn" {
  value = aws_kinesis_stream.kinesis_stream.arn
}
