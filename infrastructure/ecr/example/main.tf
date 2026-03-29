# ECR repositories with AES256 encryption. Image scanning on push is disabled
# by default — enable it per-repository if your workflow requires it.

module "ecr" {
  source = "../"

  registries_name = [
    "example-customer/api", # change to your service names
    "example-customer/worker",
    "example-customer/frontend",
  ]
}
