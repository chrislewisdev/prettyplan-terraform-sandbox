provider "aws" {
  region = "ap-southeast-2"
}

########## Lambda Policy ##########
resource "aws_iam_role" "role" {
  name = "test-go-lambda-role"

  assume_role_policy = "${file("${path.module}/lambda-role-assume-policy.json")}"
}

resource "aws_iam_policy" "role_policy" {
  name   = "test-go-lambda-execution-policy"
  policy = "${file("${path.module}/lambda-execution-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn = "${aws_iam_policy.role_policy.arn}"
  role       = "${aws_iam_role.role.name}"
}

########## Lambda ##########
resource "aws_lambda_function" "function" {
  function_name = "test-go-lambda"

  filename         = "build/begin.zip"
  source_code_hash = "${base64sha256(file("build/begin.zip"))}"

  runtime     = "go1.x"
  handler     = "begin"
  role        = "${aws_iam_role.role.arn}"
  memory_size = "128"
  timeout     = "100"
}

resource "aws_lambda_permission" "invoke_permission" {
  statement_id  = "AllowAPIGatewayInvokeTestLambda"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.function.arn}"
  principal     = "apigateway.amazonaws.com"
}

########## API Gateway ##########
resource "aws_api_gateway_rest_api" "api" {
  name = "test-go-lambda-api"
}

resource "aws_api_gateway_resource" "hello_endpoint" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id   = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part   = "hello"
}

resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = "${aws_api_gateway_rest_api.api.id}"
  resource_id   = "${aws_api_gateway_resource.hello_endpoint.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_invoke" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.hello_endpoint.id}"
  http_method = "${aws_api_gateway_method.hello_method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "aws_api_gateway_integration.hello_invoke"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "live"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}