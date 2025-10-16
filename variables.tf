variable "enabled" {
  type        = bool
  default     = true
  description = "Enable or disable creation of resources"
}

variable "engine" {
  type        = string
  default     = ""
  description = "Database engine (mysql, postgres, db2)"
}

variable "engine_version" {
  type        = string
  default     = ""
}

variable "identifier" {
  type        = string
  default     = ""
}

variable "skip_final_snapshot" {
  description = "Set to true to skip final snapshot when deleting RDS instance"
  type        = bool
  default     = true
}


variable "instance_class" {
  type        = string
  default     = ""
}

variable "allocated_storage" {
  type        = string
  default     = ""
}

variable "max_allocated_storage" {
  type        = string
  default     = null
}

variable "backup_retention_period" {
  type    = number
  default = 14
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
  default = false
}

variable "username" {
  type    = string
  default = "admin"
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
  type    = string
  default = "gp3"
}

variable "iops" {
  type    = number
  default = 3000
}

variable "storage_throughput" {
  type    = number
  default = 125
}

variable "parameter_group_name" {
  type    = string
  default = "default.mysql8.0"
}

variable "option_group_name" {
  type    = string
  default = ""
}

variable "copy_tags_to_snapshot" {
  type    = bool
  default = true
}

variable "enabled_cloudwatch_logs_exports" {
  type    = list(string)
  default = []
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

# DB2 BYOL specific
variable "license_model" {
  type    = string
  default = "bring-your-own-license"
}

variable "ibm_customer_id" {
  type    = string
  default = ""
}

variable "ibm_site_id" {
  type    = string
  default = ""
}

variable "db2_family" {
  type    = string
  default = "db2-ae-11.5"
}

variable "snapshot_identifier" {
  type    = string
  default = null
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}

variable "ca_cert_identifier" {
  type    = string
  default = "rds-ca-rsa2048-g1"
}
