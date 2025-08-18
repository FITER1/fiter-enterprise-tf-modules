variable "instance_type" {
  type        = string
  description = "Description: The type of instance to start"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Key name of the Key Pair to use for the instance"
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Whether to associate a public IP address with an instance in a VPC"
  default     = null
}

variable "create_timeout" {
  type        = string
  description = "value of the timeout to create the resource"
  default     = "10m"
}

variable "delete_timeout" {
  type        = string
  description = "value of the timeout to delete the resource"
  default     = "10m"
}

variable "ami_image_id" {
  type        = string
  description = "ID of AMI to use for the instance"
  default     = ""
}

variable "create_key_pair" {
  type        = bool
  description = "Create AWS Key Pair, Set to False if Key already exists in AWS"
  default     = false
}

variable "instance_name" {
  type        = string
  description = "Name to be used on EC2 instance created"
}

variable "disable_api_termination" {
  type        = bool
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "enable_hibernation_support" {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = false
}

variable "create_security_group" {
  type        = bool
  default     = true
  description = "Create EC2 Security Group, Set to False to Use Existing Security Group"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of Existing Security Groups to Use, Ignored if Create Security Group is enabled"
  default     = []
}

variable "sg_ingress_cidr" {
  type        = list(string)
  description = "List of CIDRs to Allow in Security Group, Defaults to the VPC CIDR if ignored. (Deprecated in favor of sg_ingress_rules)"
  default     = []
}

variable "sg_ingress_rules" {
  type        = map(any)
  description = "Map of Security Group Ingress Rules to Add, Ignored if Create Security"
  default     = {}
}

variable "sg_ingress_ports" {
  type        = list(number)
  description = "List of Ingress Ports to Allow in Security Group (Deprecated in favor of sg_ingress_rules)"
  default     = [80]
}

variable "sg_ingress_protocol" {
  type        = string
  description = "Ingress Protocol Name (Deprecated in favor of sg_ingress_rules)"
  default     = "tcp"
}

variable "subnets" {
  type        = list(string)
  description = "Name of VPC Subnets to Deploy EC2"
}

variable "ebs_volume_size" {
  type        = number
  description = "EBS Volume Size"
  default     = 50
}

variable "ebs_volume_type" {
  type        = string
  description = "EBS Volume Type"
  default     = "gp3"
}

variable "enable_encrypted_volume" {
  type        = bool
  description = "Enable EBS Volume Encryption"
  default     = true
}

variable "instance_iam_policies" {
  type        = map(any)
  description = "Map of Policies to Add to Instance Profile"
  default     = {}
}

variable "additional_ebs_volumes" {
  type        = list(any)
  description = "List of Map of Additional EBS Volumes"
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "Compulsory Tags For Terraform Resources, Must Contain Tribe, Squad and Domain"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instance will be launched"
}

variable "environment" {
  type        = string
  description = "Environment for the resources, e.g., dev, staging, prod"
}

variable "default_ami_filter" {
  type        = string
  description = "Default AMI filter to use if ami_image_id is not provided"
  default     = "al2023-ami-2023.*-kernel-6.1-*"
}

variable "user_data_base64" {
  type        = string
  description = "Base64 encoded user data script to run on instance launch"
  default     = null
}

variable "user_data" {
  type        = string
  description = "User data script to run on instance launch"
  default     = null
}

variable "user_data_replace_on_change" {
  type        = bool
  description = "Whether to replace the user data script on change"
  default     = false
}

variable "create_eip" {
  type        = bool
  description = "Whether to create an Elastic IP for the instance"
  default     = false
}
