output "topic_ids" {
  description = "Mapeo de nombre → ID de cada topic creado"
  value       = { for k, r in confluent_kafka_topic.this : k => r.id }
}

output "topic_names" {
  description = "Lista de nombres de topics creados"
  value       = keys(confluent_kafka_topic.this)
}
