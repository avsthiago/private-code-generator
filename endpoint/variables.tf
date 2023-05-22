variable "region" {
  description = "AWS region"
}

variable "ecr_repository_endpoint_name" {
  description = "Name of the ECR repository where the Docker image for the endpoint is stored"
}

variable "model_name" {
  description = "Name of the SageMaker model"
}

variable "image_tag" {
  description = "Docker image tag"
}

variable "endpoint_name" {
  description = "Name of the SageMaker endpoint"
}

variable "instance_type" {
  description = "SageMaker endpoint instance type"
}

variable "model_bucket_name" {
  description = "Name of the S3 bucket to store the model binaries"
}
