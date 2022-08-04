variable "bucket_name" {
  description = "The name of Kyle's S3 bucket. Must be globally unique"
  default     = "kyle-aviatrix-s3-bucket"
}

variable "aws_region" {
  description = "My default deployment region"
  type        = string
  default     = "us-east-1"
}
