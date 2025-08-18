module "infra_security_group" {
  source = "../"
  name   = "dev-infra-sg"
  vpc_id = "vpc-001"
  security_group_rules = [{
    name        = "user-1"
    ip          = "123.4.5.4/32"
    description = "Grant Access to DB from user 1"
  }]
  ports = [443]
  tags = {
    component   = "infra"
    environment = "dev"
  }

}
