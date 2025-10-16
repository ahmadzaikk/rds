# Output the Endpoint(w/ port) of the RDS instance
output "rds_endpoint" {
  description = "RDS EndPoint"
  value       = join("", aws_db_instance.this.*.endpoint)
}

# Output the ID of the RDS instance
output "rds_instance_name" {
  value = join("", aws_db_instance.this.*.id)
}

# Output only Address of RDS instance
output "rds_address" {
  value = join("", aws_db_instance.this.*.address)
}

# Output the KMS Key ID used for the RDS instance
output "rds_kms_key_id" {
  value = join("", aws_db_instance.this.*.kms_key_id)
}

# Output the Subnet Group ID
output "db_subnet_group" {
  value = join("", aws_db_subnet_group.this.*.id)
}

# Output the Secrets Manager ID
output "secret_id" {
  description = "[secret id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#id)"
  value       = join("", aws_secretsmanager_secret.this.*.id)
}

# Output the Secrets Manager Name
output "secret_manager_name" {
  description = "[secret name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret#name)"
  value       = join("", aws_secretsmanager_secret.this.*.name)
}

# ===== Db2-specific outputs =====
output "db2_parameter_group" {
  description = "Db2 Parameter Group Name"
  value       = var.engine == "db2" ? aws_db_parameter_group.db2_param_group.name : null
}

output "db2_option_group" {
  description = "Db2 Option Group Name"
  value       = var.engine == "db2" ? aws_db_option_group.Db2_option_group.name : null
}

output "db2_port" {
  description = "Db2 TCP Port"
  value       = var.engine == "db2" ? var.tcp_port : null
}

output "db2_name" {
  description = "Db2 Initial Database Name"
  value       = var.engine == "db2" ? var.db_name : null
}
