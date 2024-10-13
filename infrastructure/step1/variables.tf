variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "The VPC ID to deploy EKS and other resources"
  type        = string
  default     = "vpc-04ebacdeb6e29a15b"
}

variable "subnet_ids" {
  description = "List of subnets to deploy resources"
  type        = list(string)
  default = [ "subnet-0f0c148076993686a", "subnet-0e9119f4c75c911d1" ]
}

variable "eks_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  default     = "t2.micro"
}

variable "rds_instance_type" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "rds_username" {
  description = "Database username"
  default     = "admin"
}

variable "rds_password" {
  description = "Database password"
  default = "strong-password"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  default     = "ecommerce-app-bucket"
}

variable "elasticsearch_instance_type" {
  description = "Elasticsearch instance type"
  default     = "t3.small.elasticsearch"
}
