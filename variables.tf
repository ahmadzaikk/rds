variable "enabled" {
  type        = bool
  default     = true
  description = "Enable or disable creation of resources"
}

variable "engine" {
  type        = string
  description = "Database engine (mysql, postgres, db2-se)"
  default     = "db2-se"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
  default     = "11.5.8.0"
}

variable "identifier" {
  type        = string
  description = "RDS instance identifier"
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Set to true to skip final snapshot when deleting RDS instance"
  type        = bool
  default     = true
}

variable "instance_class" {
  type        = string
  description = "RDS instance class"
  default     = "db.m6i.large"
}

variable "allocated_storage" {
  type        = number
  description = "Allocated storage in GB (DB2 requires minimum 400GB)"
  default     = 400
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage for autoscaling"
  default     = 500
}

variable "backup_retention_period" {
  type        = number
  default     = 28
}

variable "backup_window" {
  type    = string
  default = null
}

variable "maintenance_window" {
  type    = string
  default = null
}

variable "multi_az" {
  type    = bool
  default = false
}

variable "publicly_accessible" {
  type    = bool
  default = false
}

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "apply_immediately" {
  type    = bool
  default = true
}

variable "manage_master_user_password" {
  type    = bool
  default = true
}

variable "username" {
  type    = string
  default = "db2admin"
}

variable "secret_manager_name" {
  type    = string
  default = ""
}

variable "storage_encrypted" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "create_cmk" {
  type    = bool
  default = false
}

variable "cmk_multi_region" {
  type    = bool
  default = false
}

variable "cmk_allowed_aws_account_ids" {
  type    = list(string)
  default = []
}

variable "storage_type" {
  type        = string
  description = "Storage type (gp3 for MySQL/Postgres, gp3 for DB2)"
  default     = "gp3"
}

variable "iops" {
  type        = number
  description = "IOPS (not required for DB2-SE)"
  default     = null
}

variable "storage_throughput" {
  type        = number
  description = "Storage throughput in MB/s (optional for gp3)"
  default     = null
}

variable "parameter_group_name" {
  type    = string
  default = null
}

variable "option_group_name" {
  type    = string
  default = null
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = ["audit", "error"]
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

# DB2 BYOL-specific
variable "license_model" {
  type        = string
  description = "License model for DB2 (BYOL required)"
  default     = "general-public-license"
}

variable "ibm_customer_id" {
  type        = string
  description = "IBM customer ID for DB2 BYOL"
  default     = ""
}

variable "ibm_site_id" {
  type        = string
  description = "IBM site ID for DB2 BYOL"
  default     = ""
}

variable "db2_family" {
  type        = string
  description = "DB2 family name"
  default     = "db2-ae-11.5"
}

variable "snapshot_identifier" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type    = bool
  default = true
}

variable "ca_cert_identifier" {
  type    = string
  default = "rds-ca-rsa2048-g1"
}
