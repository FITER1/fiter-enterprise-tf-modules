/**
 * # AWS EC2 Terraform module
 *
 * This module creates an AWS [EC2 Instances](https://aws.amazon.com/ec2/) on AWS.
 *
 * Resources needed to support the ec2 instance such as Keypair, Security Group are created as part of the module.
 * The Generated Key is stored under System Manager Parameter store with the Instance name. Instance can also be accessed using Session Manager which is deployed as part of the module.
 *
 */

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = [
      "amzn-ami-*",
    ]
  }
}

resource "random_shuffle" "subnet" {
  input        = local.map_subnets
  result_count = 1
}

module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.3"
  create             = var.create_key_pair
  key_name           = local.key_name
  create_private_key = true
  tags               = local.common_tags
}

resource "aws_ssm_parameter" "aws_key_pair" {
  count = var.create_key_pair ? 1 : 0

  name  = "/fineract/ec2/key_pair/${local.key_name}"
  type  = "SecureString"
  value = module.key_pair.private_key_pem
  tags  = local.common_tags
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5.5.0"

  ami                         = var.ami_image_id != "" ? var.ami_image_id : data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  name                        = var.instance_name
  key_name                    = local.key_name
  vpc_security_group_ids      = local.security_group_ids
  subnet_id                   = local.subnet_id
  ignore_ami_changes          = true
  create_iam_instance_profile = true
  iam_role_name               = var.instance_name
  iam_role_description        = "IAM role for ${var.instance_name} EC2 instance"
  iam_role_policies = merge(var.instance_iam_policies, {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  })

  disable_api_termination     = var.disable_api_termination
  associate_public_ip_address = var.associate_public_ip_address
  hibernation                 = var.enable_hibernation_support

  tags = local.common_tags

  root_block_device = [
    {
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
      encrypted   = var.enable_encrypted_volume
    }
  ]

  timeouts = {
    create = var.create_timeout
    delete = var.delete_timeout
  }
}

resource "aws_security_group" "this" {
  count = var.create_security_group ? 1 : 0

  name        = "ec2-${var.instance_name}-sg"
  description = "EC2 ${var.instance_name} security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset(var.sg_ingress_ports)

    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.sg_ingress_protocol
      cidr_blocks = local.security_group_cidr
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = local.common_tags
}

resource "aws_volume_attachment" "data" {
  for_each = { for volume in var.additional_ebs_volumes : volume.name => volume }

  device_name = each.value.device_name
  instance_id = module.ec2.id
  volume_id   = aws_ebs_volume.data[each.key].id
}

resource "aws_ebs_volume" "data" {
  for_each = { for volume in var.additional_ebs_volumes : volume.name => volume }

  availability_zone = local.map_subnets[local.subnet_id]["subnet_az"]
  size              = each.value.size
  type              = each.value.type
  tags              = local.common_tags
}
