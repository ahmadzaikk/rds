#########################################################
# AWS RDS DB2 Terraform Module
#########################################################

# Get current AWS account info
data "aws_caller_identity" "this" {}

#########################################################
# DB Subnet Group
#########################################################
resource "aws_db_subnet_group" "this" {
  count       = var.enabled ? 1 : 0
  name        = "${var.identifier}-subnet-group"
  description = "Created by Terraform"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

#########################################################
# Random password for Secrets Manager
#########################################################
resource "random_password" "password" {
  length           = 12
  special          = true
  min_special      = 2
  override_special = "_%"
}

#########################################################
# Secrets Manager secret
#########################################################
resource "aws_secretsmanager_secret" "this" {
  count                   = var.manage_master_user_password ? 0 : 1
  name                    = var.secret_manager_name
  recovery_window_in_days = 7
  tags                    = var.tags
}

#########################################################
# Secrets Manager secret version
#########################################################
resource "aws_secretsmanager_secret_version" "this" {
  count         = var.manage_master_user_password ? 0 : 1
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = <<EOF
{
  "username": "${var.username}",
  "password": "${random_password.password.result}"
}
EOF

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#########################################################
# Optional KMS Key (for encryption)
#########################################################
resource "aws_kms_key" "this" {
  count                    = var.create_cmk ? 1 : 0
  description              = "CMK for RDS instance ${var.identifier}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = var.cmk_multi_region
  policy                   = data.aws_iam_policy_document.this.json
  tags                     = var.tags
}

#########################################################
# KMS Alias
#########################################################
resource "aws_kms_alias" "this" {
  count         = var.create_cmk ? 1 : 0
  name          = "alias/ucop/rds/${var.identifier}"
  target_key_id = aws_kms_key.this.*.key_id[0]
}

#########################################################
# KMS Policy
#########################################################
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow use of the key"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    principals {
      type        = "AWS"
      identifiers = [for account_id in concat([data.aws_caller_identity.this.account_id], var.cmk_allowed_aws_account_ids) : "arn:aws:iam::${account_id}:root"]
    }
  }

  statement {
    sid       = "Allow attachment of persistent resources"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }

    principals {
      type        = "AWS"
      identifiers = [for account_id in concat([data.aws_caller_identity.this.account_id], var.cmk_allowed_aws_account_ids) : "arn:aws:iam::${account_id}:root"]
    }
  }
}

#########################################################
# DB2 Parameter Group
#########################################################
resource "aws_db_parameter_group" "db2_param_group" {
  count  = contains(["db2", "db2-se", "db2-ae"], var.engine) ? 1 : 0
  name   = "${var.identifier}-db2-param-group"
  family = var.db2_family

  parameter {
    apply_method = "immediate"
    name         = "rds.ibm_customer_id"
    value        = var.ibm_customer_id
  }

  parameter {
    apply_method = "immediate"
    name         = "rds.ibm_site_id"
    value        = var.ibm_site_id
  }

  tags = var.tags
}

#########################################################
# RDS DB Instance (DB2-safe)
#########################################################
resource "aws_db_instance" "this" {
  count                     = var.enabled ? 1 : 0
  identifier                = var.identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  license_model             = var.license_model
  allocated_storage         = var.allocated_storage
  max_allocated_storage     = var.max_allocated_storage
  storage_type              = var.storage_type

  # Only include IOPS/throughput if not DB2
  dynamic "iops" {
    for_each = contains(["db2", "db2-se", "db2-ae"], var.engine) ? [] : [1]
    content {
      iops = var.iops
    }
  }

  dynamic "storage_throughput" {
    for_each = contains(["db2", "db2-se", "db2-ae"], var.engine) ? [] : [1]
    content {
      storage_throughput = var.storage_throughput
    }
  }

  storage_encrypted         = var.storage_encrypted
  kms_key_id                = var.create_cmk ? aws_kms_key.this.*.arn[0] : var.kms_key_id
  db_subnet_group_name      = aws_db_subnet_group.this.*.id[0]
  vpc_security_group_ids    = var.vpc_security_group_ids
  publicly_accessible       = var.publicly_accessible
  parameter_group_name      = contains(["db2", "db2-se", "db2-ae"], var.engine) ? aws_db_parameter_group.db2_param_group[0].name : var.parameter_group_name
  option_group_name         = var.option_group_name
  multi_az                  = var.multi_az
  manage_master_user_password = var.manage_master_user_password ? true : null
  username                  = var.manage_master_user_password ? var.username : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["username"]
  password                  = var.manage_master_user_password ? null : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["password"]
  backup_retention_period   = var.backup_retention_period
  backup_window             = var.backup_window
  maintenance_window        = var.maintenance_window
  apply_immediately         = var.apply_immediately
  skip_final_snapshot       = var.skip_final_snapshot
  copy_tags_to_snapshot     = var.copy_tags_to_snapshot
  performance_insights_enabled = var.performance_insights_enabled
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  tags                      = var.tags
}
