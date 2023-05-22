resource "aws_api_gateway_rest_api" "api" {
  name        = "SageMakerAPI"
  description = "API Gateway for SageMaker Endpoint"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "SageMakerAPIGatewayRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "apigateway.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
    ]
}
EOF

  managed_policy_arns = [aws_iam_policy.api_gateway_policy.arn]
}

# create the iam policy to allow api gateway to invoke sagemaker endpoint
resource "aws_iam_policy" "api_gateway_policy" {
  name        = "SageMakerAPIGatewayPolicy"
  description = "IAM Policy for API Gateway to invoke SageMaker Endpoint"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Action": [
            "sagemaker:InvokeEndpoint"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:sagemaker:${var.region}:${local.account_id}:endpoint/${aws_sagemaker_endpoint.endpoint.name}"
        ]
        }
    ]
}
EOF
}

resource "aws_api_gateway_method" "generate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "generate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.generate.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration" "generate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.generate.http_method

  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:runtime.sagemaker:path//endpoints/${aws_sagemaker_endpoint.endpoint.name}/invocations"
  credentials             = aws_iam_role.api_gateway_role.arn
}

resource "aws_api_gateway_integration_response" "generate" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.generate.http_method
  status_code = aws_api_gateway_method_response.generate.status_code
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration_response.generate]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "generate" {
  depends_on = [aws_api_gateway_deployment.deployment]
  rest_api_id = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  stage_name = "generate"
}
