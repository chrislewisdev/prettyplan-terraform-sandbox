provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "test-go-lambda-api"
}

module "hello_endpoint" {
  source = "modules/lambda-endpoint"

  api_id = "${aws_api_gateway_rest_api.api.id}"
  api_root_resource_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  filename = "build/hello.zip"
  handler_name = "hello"
  endpoint_name = "hello"
}

module "bye_endpoint" {
  source = "modules/lambda-endpoint"

  api_id = "${aws_api_gateway_rest_api.api.id}"
  api_root_resource_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  filename = "build/bye.zip"
  handler_name = "bye"
  endpoint_name = "bye"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    "module.hello_endpoint",
    "module.bye_endpoint"
  ]

  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "live"
}

output "api_url" {
  value = "${aws_api_gateway_deployment.api_deployment.invoke_url}"
}