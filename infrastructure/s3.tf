resource "aws_s3_bucket" "ecommerce_bucket" {
  bucket = var.s3_bucket_name
}
