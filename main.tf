############################################
# AWS Account Info
############################################
data "aws_caller_identity" "this" {}

############################################
# DB Subnet Group
############################################
resource "aws_db_subnet_group" "this" {
  count       = var.enabled ? 1 : 0
  name        = "${var.identifier}-subnet-group"
  description = "Created by Terraform"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

############################################
# Random Password (if not using AWS-managed password)
############################################
resource "random_password" "password" {
  length           = 12
  special          = true
  min_special      = 2
  override_special = "_%"
}

############################################
# Secrets Manager Secret
############################################
resource "aws_secretsmanager_secret" "this" {
  count                   = var.manage_master_user_password ? 0 : 1
  name                    = var.secret_manager_name
  recovery_window_in_days = 7
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count         = var.manage_master_user_password ? 0 : 1
  secret_id     = aws_secretsmanager_secret.this[0].id
  secret_string = jsonencode({
    username = var.username
    password = random_password.password.result
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

############################################
# Optional KMS Key
############################################
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "EnableIAMUserPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:root"]
    }
  }

  statement {
    sid     = "AllowUseOfTheKey"
    effect  = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [for account_id in concat([data.aws_caller_identity.this.account_id], var.cmk_allowed_aws_account_ids) : "arn:aws:iam::${account_id}:root"]
    }
  }

  statement {
    sid     = "AllowAttachmentOfPersistentResources"
    effect  = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]
    resources = ["*"]

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

resource "aws_kms_key" "this" {
  count                    = var.create_cmk ? 1 : 0
  description              = "CMK for RDS instance ${var.identifier}"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  multi_region             = var.cmk_multi_region
  policy                   = data.aws_iam_policy_document.this.json
  tags                     = var.tags
}

resource "aws_kms_alias" "this" {
  count         = var.create_cmk ? 1 : 0
  name          = "alias/ucop/rds/${var.identifier}"
  target_key_id = aws_kms_key.this[0].key_id
}

############################################
# DB2 Parameter Group (BYOL)
############################################
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

############################################
# RDS DB Instance
############################################
resource "aws_db_instance" "this" {
  count                        = var.enabled ? 1 : 0
  identifier                   = var.identifier
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  license_model                = var.license_model
  allocated_storage            = var.allocated_storage
  max_allocated_storage        = var.max_allocated_storage
  storage_type                 = var.storage_type
  storage_encrypted            = var.storage_encrypted
  kms_key_id                   = var.create_cmk ? aws_kms_key.this[0].arn : var.kms_key_id
  db_subnet_group_name         = aws_db_subnet_group.this[0].id
  vpc_security_group_ids       = var.vpc_security_group_ids
  publicly_accessible          = var.publicly_accessible
  multi_az                     = var.multi_az
  deletion_protection          = var.deletion_protection
  apply_immediately            = var.apply_immediately
  backup_retention_period      = var.backup_retention_period
  backup_window                = var.backup_window
  maintenance_window           = var.maintenance_window
  copy_tags_to_snapshot        = var.copy_tags_to_snapshot
  performance_insights_enabled = var.performance_insights_enabled
  ca_cert_identifier           = var.ca_cert_identifier

  # Conditional IOPS / throughput only for non-DB2-SE engines
  iops               = var.engine == "db2-se" ? null : var.iops
  storage_throughput = var.engine == "db2-se" ? null : var.storage_throughput

  parameter_group_name = contains(["db2", "db2-se", "db2-ae"], var.engine) ? aws_db_parameter_group.db2_param_group[0].name : var.parameter_group_name
  option_group_name    = var.option_group_name

  # Master credentials
  manage_master_user_password = var.manage_master_user_password ? true : null
  username = var.manage_master_user_password ? var.username : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["username"]
  password = var.manage_master_user_password ? null : jsondecode(aws_secretsmanager_secret_version.this[0].secret_string)["password"]

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  tags = var.tags

  depends_on = [
    aws_db_parameter_group.db2_param_group
  ]
}
