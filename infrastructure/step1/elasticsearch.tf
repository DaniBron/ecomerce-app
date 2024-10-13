provider "aws" {
  region = "us-east-1"  # Specify your preferred AWS region
}

resource "aws_elasticsearch_domain" "ecommerce_search" {
  domain_name           = "ecommerce-search"
  elasticsearch_version = "OpenSearch_1.0"  # Using OpenSearch version 1.0
  
  cluster_config {
    instance_type  = "t3.small.elasticsearch"  # Correct instance type for OpenSearch
    instance_count = 1
  }

  ebs_options {
    ebs_enabled  = true
    volume_size  = 10  # 10GB EBS volume
  }

  encrypt_at_rest {
    enabled = true  # Enable encryption at rest
  }

  node_to_node_encryption {
    enabled = true  # Enable node-to-node encryption
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled  = true
    master_user_options {
      master_user_name     = "admin"  
      master_user_password = "StrongPassword123!"
    }
  }

  domain_endpoint_options {
    enforce_https = true  
  }

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:049088564626:domain/ecommerce-search/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:us-east-1:049088564626:domain/ecommerce-search/*",
      "Condition": {
        "StringEquals": {
          "es:username": "admin"
        }
      }
    }
  ]
}
POLICIES


  tags = {
    Name        = "OpenSearch Cluster"
    Environment = "dev"
  }
}
