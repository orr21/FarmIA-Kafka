output "cluster_id" {
  description = "ID del cluster Kafka"
  value       = confluent_kafka_cluster.this.id
}

output "cluster_rbac_crn" {
  description = "CRN para RBAC sobre este cluster"
  value       = confluent_kafka_cluster.this.rbac_crn
}

output "rest_endpoint" {
  description = "REST endpoint del Kafka cluster"
  value       = confluent_kafka_cluster.this.rest_endpoint
}

output "api_key" {
  description = "API Key para Kafka (app-manager)"
  value       = confluent_api_key.kafka.id
}

output "api_secret" {
  description = "API Secret para Kafka (app-manager)"
  value       = confluent_api_key.kafka.secret
  sensitive   = true
}

output "service_account_id" {
  description = "ID del service account app-manager"
  value       = confluent_service_account.app_manager.id
}

output "schema_registry_cluster_id" {
  description = "ID del cluster de Schema Registry"
  value       = data.confluent_schema_registry_cluster.this.id
}

output "schema_registry_rest_endpoint" {
  description = "REST endpoint del Schema Registry"
  value       = data.confluent_schema_registry_cluster.this.rest_endpoint
}

output "schema_registry_api_key" {
  description = "API Key para conectarse a Schema Registry"
  value       = confluent_api_key.registry_key.id
}

output "schema_registry_api_secret" {
  description = "API Secret para Schema Registry"
  value       = confluent_api_key.registry_key.secret
  sensitive   = true
}
