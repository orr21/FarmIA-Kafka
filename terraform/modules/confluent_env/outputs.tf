output "environment_id" {
  value       = confluent_environment.this.id
  description = "Confluent Cloud environment ID"
}

output "environment_rn" {
  value       = confluent_environment.this.resource_name
  description = "Confluent Cloud environment Resource Name"
}

output "env_manager_service_account_id" {
  value       = confluent_service_account.env_manager.id
  description = "Environment management service account ID"
}
