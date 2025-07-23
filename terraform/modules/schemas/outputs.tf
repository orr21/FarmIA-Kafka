output "schema_ids" {
  description = "Mapeo de subject → esquema ID registrado"
  value       = { for k, r in confluent_schema.this : k => r.id }
}