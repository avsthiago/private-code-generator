variable "model_bucket_name" {
    type = string
    description = "Name of the S3 bucket to store the model binaries."
}

variable "ecr_repository_endpoint_name" {
  type = string
  description = "value for the ECR repository name"
}