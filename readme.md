# Prettyplan Terraform Sandbox

This repo contains a set of Terraform infrastructure that is used simply as a playground for generating realistic Terraform plans to use when testing Prettyplan.

It is intended to have enough complexity that you can create plans that cover most Terraform cases (updates/creates/deletes, modules, etc), while also being small enough that you can deploy it into your own AWS account without having to worry about incurring any significant costs.

Currently, it defines a single Lambda + API Gateway integration for a basic "Hello World"-esque API endpoint, but I plan on adding more over time.

## Building/Deploying

The Lambda is built using Go, so you must have that installed before proceeding.

The build scripts are written as Windows Batch files, but if you're on a different platform you could convert them to Shell scripts quite easily - they mostly contain Go commands that will work on any platform.

Run:
1. `install-dependencies.bat`
2. `build.bat`
3. `terraform apply`

From there, you can modify the Terraform as you like and re-apply to create different permutations of Terraform plans. (and don't forget to `terraform destroy` once you're done to clean up what you've deployed)