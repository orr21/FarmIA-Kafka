output "ksql_cluster_id" {
  value       = confluent_ksql_cluster.this.id
  description = "ksqlDB cluster ID"
}

output "ksql_rest_endpoint" {
  value       = confluent_ksql_cluster.this.rest_endpoint
  description = "ksqlDB REST endpoint"
}

output "ksql_api_key" {
  value       = confluent_api_key.ksql_key.id
}

output "ksql_api_secret" {
  value     = confluent_api_key.ksql_key.secret
  sensitive = true
}