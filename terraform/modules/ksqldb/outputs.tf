output "ksql_cluster_id" {
  value       = confluent_ksql_cluster.this.id
  description = "ID del clúster ksqlDB"
}

output "ksql_rest_endpoint" {
  value       = confluent_ksql_cluster.this.rest_endpoint
  description = "REST endpoint de ksqlDB"
}

output "ksql_api_key" {
  value       = confluent_api_key.ksql_key.id
}

output "ksql_api_secret" {
  value     = confluent_api_key.ksql_key.secret
  sensitive = true
}