data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_sagemaker_model" "model" {
  name               = var.model_name
  execution_role_arn = aws_iam_role.sagemaker_role.arn

  primary_container {
    image = "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/${var.ecr_repository_endpoint_name}:${var.image_tag}"
  }
}

resource "aws_sagemaker_endpoint_configuration" "ec" {
  name = "${var.model_name}-config"
  production_variants {
    variant_name           = "default"
    model_name             = aws_sagemaker_model.model.name
    initial_instance_count = 1
    instance_type          = var.instance_type
  }
}

resource "aws_sagemaker_endpoint" "endpoint" {
  name                 = var.endpoint_name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name

  deployment_config {
    blue_green_update_policy {
      
      traffic_routing_configuration {
        wait_interval_in_seconds = 0
        type = "ALL_AT_ONCE"
      }
    }
  }
}
