variable "api_id" {}
variable "api_root_resource_id" {}
variable "filename" {}
variable "handler_name" {}
variable "endpoint_name" {}

########## Lambda Policy ##########
resource "aws_iam_role" "role" {
  name = "test-go-lambda-${var.endpoint_name}-role"

  assume_role_policy = "${file("${path.module}/lambda-role-assume-policy.json")}"
}

resource "aws_iam_policy" "role_policy" {
  name   = "test-go-lambda-${var.endpoint_name}-execution-policy"
  policy = "${file("${path.module}/lambda-execution-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  policy_arn = "${aws_iam_policy.role_policy.arn}"
  role       = "${aws_iam_role.role.name}"
}

########## Lambda ##########
resource "aws_lambda_function" "function" {
  function_name = "test-go-lambda-${var.endpoint_name}"

  filename         = "${var.filename}"
  source_code_hash = "${base64sha256(file(var.filename))}"

  runtime     = "go1.x"
  handler     = "${var.handler_name}"
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

resource "aws_api_gateway_resource" "endpoint" {
  rest_api_id = "${var.api_id}"
  parent_id   = "${var.api_root_resource_id}"
  path_part   = "${var.endpoint_name}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = "${var.api_id}"
  resource_id   = "${aws_api_gateway_resource.endpoint.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "invoke" {
  rest_api_id = "${var.api_id}"
  resource_id = "${aws_api_gateway_resource.endpoint.id}"
  http_method = "${aws_api_gateway_method.method.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.function.invoke_arn}"
}