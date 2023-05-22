model_bucket_name = "private-models-xyz" # replace with your bucket name. This name must be unique across all existing bucket names in Amazon S3.
ecr_repository_endpoint_name = "private-code-generator" # You can choose any name for your ECR repository.
region= "eu-west-1"
model_name = "code-generator"
image_tag = "0.0.7"
endpoint_name =  "code-generator"
instance_type = "ml.m5.large"
