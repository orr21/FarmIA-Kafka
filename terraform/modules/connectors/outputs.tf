output "connector_names" {
  value       = keys(confluent_connector.this)
  description = "Nombres de los conectores creados"
}

output "connector_ids" {
  value       = { for k, c in confluent_connector.this : k => c.id }
  description = "IDs de los conectores"
}
