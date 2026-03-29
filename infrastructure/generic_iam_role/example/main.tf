# Generic IAM role with a trust policy and attached managed policy.
# This example creates a role that an EC2 instance can assume,
# with the SSM managed policy attached for Session Manager access.

module "ec2_iam_role" {
  source    = "../"
  role_name = "example-customer-dev-ec2" # change to your role name; "-role" is appended automatically

  common_tags = {
    Name        = "example-customer-dev-ec2-role"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  # Trust policy — which principal can assume this role
  principal_type        = "Service"
  principal_identifiers = ["ec2.amazonaws.com"] # change to the AWS service or IAM ARN that needs to assume this role

  # Attach existing managed policies by ARN
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", # allows Session Manager access
  ]

  # Optionally attach an inline policy (uncomment and provide a valid JSON policy document)
  # create_policy = true
  # role_policy   = jsonencode({
  #   Version = "2012-10-17"
  #   Statement = [{
  #     Effect   = "Allow"
  #     Action   = ["s3:GetObject"]
  #     Resource = "arn:aws:s3:::example-bucket/*"
  #   }]
  # })
}
