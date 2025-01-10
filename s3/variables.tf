variable "region" {
  description = "The AWS region"
  type        = string
  default     = "ap-northeast-2"
}
variable "access_key" {
  description = "The AWS access key"
  type        = string
  default     = "access_key"
}
variable "secret_key" {
  description = "The AWS secret_key"
  type        = string
  default     = "secret_key"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment for the resources"
  type        = string
  default     = "dev"
}

variable "cors_allowed_origin" {
  description = "The allowed origin for CORS"
  type        = string
  default     = "*"
}

variable "bucket_policy" {
  description = "The bucket policy"
  type        = string
  default     = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": []
  }
  POLICY
}
