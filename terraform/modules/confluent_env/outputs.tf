output "environment_id" {
  value       = confluent_environment.this.id
  description = "ID del environment en Confluent Cloud"
}

output "environment_rn" {
  value       = confluent_environment.this.resource_name
  description = "Resource Name del environment en Confluent Cloud"
}

output "env_manager_service_account_id" {
  value       = confluent_service_account.env_manager.id
  description = "ID del service account de gestión del environment"
}
