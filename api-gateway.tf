resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "distributed-atom-space"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "lambda" {
  path_part   = "das"
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_method" "lambda" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.lambda.id
  http_method   = "GET"
  authorization = "NONE"
}

data "aws_lambda_function" "lambda" {
  function_name = "DAS-main-lambda_function"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.lambda.id
  http_method             = aws_api_gateway_method.lambda.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda" {
  stage_name    = "prod"
  deployment_id = aws_api_gateway_deployment.lambda.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
}
