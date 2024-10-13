provider "aws" {
  alias  = "kinesis"
  region = "us-east-1"  
}

resource "aws_kinesis_stream" "kinesis_stream" {
  name             = "KINESIS_STREAM"
  retention_period = 24  

  stream_mode_details {
    stream_mode = "ON_DEMAND" 
  }

  tags = {
    Environment = "production"  
  }
}
