output "rds_endpoint" {
  value       = join("", aws_db_instance.this.*.endpoint)
  description = "RDS EndPoint with port"
}

output "rds_instance_name" {
  value = join("", aws_db_instance.this.*.id)
}

output "rds_address" {
  value = join("", aws_db_instance.this.*.address)
}

output "rds_kms_key_id" {
  value = join("", aws_db_instance.this.*.kms_key_id)
}

output "db_subnet_group" {
  value = join("", aws_db_subnet_group.this.*.id)
}

output "secret_id" {
  value       = join("", aws_secretsmanager_secret.this.*.id)
  description = "Secrets Manager ID"
}

output "secret_manager_name" {
  value       = join("", aws_secretsmanager_secret.this.*.name)
  description = "Secrets Manager Name"
}
