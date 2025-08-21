locals {
  cron_actions = {
    start = "AWS-StartRdsInstance"
    stop  = "AWS-StopRdsInstance"
  }
}

data "aws_iam_policy_document" "ssm_permission" {
  statement {
    sid     = "GrantSSMPermission"
    effect  = "Allow"
    actions = ["ssm:StartAutomationExecution"]
    resources = [
      "arn:aws:ssm:${var.region}::automation-definition/AWS-StartRdsInstance:*",
      "arn:aws:ssm:${var.region}::automation-definition/AWS-StopRdsInstance:*"
    ]
  }

  statement {
    sid    = "GrantSSMRDSPermission"
    effect = "Allow"
    actions = [
      "rds:StartDBInstance",
      "rds:StopDBInstance",
      "rds:DescribeDBInstances"
    ]
    resources = [module.db.db_instance_arn]
  }
}

module "eventbridge_scheduler_role" {
  count  = length(var.cron_schedules) > 0 ? 1 : 0
  source = "git::git@github.com:FITER1/fiter-enterprise-tf-modules.git//infrastructure//generic_iam_role?ref=1.2.0"

  create_policy         = true
  principal_type        = "Service"
  principal_identifiers = ["scheduler.amazonaws.com", "ssm.amazonaws.com"]
  role_name             = "RDSSchedulerRole${title(var.db_identifier)}"
  role_policy           = data.aws_iam_policy_document.ssm_permission.json
  common_tags           = local.tags
}

module "eventbridge_scaler" {
  for_each = {
    for schedule in var.cron_schedules : schedule.name => schedule
  }

  source  = "terraform-aws-modules/eventbridge/aws"
  version = "~> 3.17.0"

  append_schedule_postfix = false
  create_bus              = false
  create_role             = false

  schedules = {
    "${each.key}-${var.db_identifier}" = {
      description         = each.value.description
      schedule_expression = each.value.schedule_expression
      timezone            = var.scheduler_timezone
      arn                 = "arn:aws:scheduler:::aws-sdk:ssm:startAutomationExecution"
      role_arn            = module.eventbridge_scheduler_role[0].arn
      input = jsonencode({
        DocumentName = local.cron_actions[each.value.action]
        Parameters = {
          InstanceId = [module.db.db_instance_identifier]
        }
      })
    }
  }
}
