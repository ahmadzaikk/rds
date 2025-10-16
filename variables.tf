# -----------------------------
# Common RDS variables
# -----------------------------
variable "enabled" {
  default     = true
  description = "Set to `false` to prevent the module from creating any resources"
  type        = bool
}

variable "allocated_storage" {
  default     = ""
  description = "Allocate storage size in GB"
  type        = string
}

variable "max_allocated_storage" {
  type        = string
  description = "Max allocate storage"
  default     = null
}

variable "backup_retention_period" {
  default     = 14
  description = "Enable automatic backup and retention in days"
  type        = number
}

variable "backup_window" {
  description = "When to perform DB backups (UTC)"
  type        = string
  default     = null
}

variable "engine" {
  default     = ""
  description = "Specify RDS engine name (e.g., mysql, postgres, oracle, db2)"
  type        = string
}

variable "engine_version" {
  default     = ""
  description = "Specify DB engine version"
  type        = string
}

variable "identifier" {
  default     = ""
  description = "DB instance identifier"
  type        = string
}

variable "instance_class" {
  default     = ""
  description = "Specify DB instance type"
  type        = string
}

variable "multi_az" {
  default     = false
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
}

variable "publicly_accessible" {
  default     = false
  description = "Set to `false` to prevent public database accessibility"
  type        = bool
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the DB instance"
  default     = []
}

variable "username" {
  type        = string
  description = "Username for the master DB user"
  default     = "admin"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = false
}

variable "secret_manager_name" {
  type        = string
  description = "Secrets Manager secret name for master user"
  default     = ""
}

variable "password" {
  type        = string
  description = "(Optional) Master password if manage_master_user_password is false"
  default     = ""
}

variable "skip_final_snapshot" {
  default     = true
  description = "Set to `false` to prevent skipping final snapshot on deletion"
  type        = bool
}

variable "copy_tags_to_snapshot" {
  description = "On delete, copy all instance tags to the final snapshot"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  default     = true
  description = "Set to `false` to prevent database deletion"
  type        = bool
}

variable "apply_immediately" {
  default     = true
  description = "Set to `false` to prevent immediate changes"
  type        = bool
}

variable "parameter_group_name" {
  default     = "default.mysql8.0"
  description = "RDS parameter group name"
}

variable "option_group_name" {
  default     = ""
  description = "RDS option group name"
}

variable "ca_cert_identifier" {
  type        = string
  description = "The identifier of the CA certificate for the DB instance"
  default     = "rds-ca-rsa2048-g1"
}

variable "storage_encrypted" {
  default     = true
  description = "Set to `false` to not encrypt the storage"
  type        = bool
}

variable "kms_key_id" {
  default     = null
  description = "(Optional) ARN of existing KMS encryption key to use for storage encryption"
  type        = string
}

variable "create_cmk" {
  default     = false
  description = "Create a customer-managed KMS key (CMK) for storage encryption"
  type        = bool
}

variable "cmk_multi_region" {
  default     = false
  description = "Create CMK as a multi-region key (only applicable if create_cmk = true)"
  type        = bool
}

variable "cmk_allowed_aws_account_ids" {
  type        = list(string)
  description = "List of other AWS account IDs allowed access to the CMK"
  default     = []
}

variable "storage_type" {
  default     = "gp3"
  description = "gp2, gp3 (default), or io1"
  type        = string
}

variable "storage_throughput" {
  default     = 125
  description = "(Optional) The storage throughput value for the DB instance (gp3 only)"
  type        = number
}

variable "iops" {
  default     = 3000
  description = "(Optional) The amount of provisioned IOPS"
  type        = number
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs"
  type        = list(string)
  default     = []
}

variable "maintenance_window" {
  description = "Preferred maintenance window in UTC"
  type        = string
  default     = null
}

# -----------------------------
# Db2-specific variables
# -----------------------------
variable "major_engine_version" {
  description = "Major engine version for Db2"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Initial database name for Db2"
  type        = string
  default     = ""
}

variable "tcp_port" {
  description = "TCP port for Db2 instance"
  type        = number
  default     = 0
}

variable "ssl_port" {
  description = "SSL port for Db2 instance"
  type        = number
  default     = 0
}

variable "license_model" {
  description = "License model for Db2 (license-included, marketplace-license)"
  type        = string
  default     = ""
}

variable "enhanced_monitoring_enabled" {
  description = "Enable enhanced monitoring for Db2"
  type        = bool
  default     = false
}

variable "alert_email_address" {
  description = "Email address to receive alerts for Db2 events"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "VPC CIDR block used for Db2 security group"
  type        = string
  default     = ""
}

variable "family" {
  description = "DB parameter group family for Db2"
  type        = string
  default     = ""
}

variable "ibm_customer_id" {
  description = "IBM Customer ID for Db2"
  type        = string
  default     = ""
}

variable "ibm_site_id" {
  description = "IBM Site ID for Db2"
  type        = string
  default     = ""
}

variable "db2_parameters" {
  description = "List of Db2 parameters to configure in the parameter group"
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []
}

variable "s3_bucket_name" {
  description = "S3 bucket used for Db2 integration"
  type        = string
  default     = ""
}
