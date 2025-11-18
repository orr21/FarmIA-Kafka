variable "environment_id" {
  type        = string
  description = "Confluent Cloud environment ID where to find the Schema Registry"
}

variable "schema_registry_cluster_id" {
  type        = string
  description = "Schema Registry ID"
}

variable "schema_registry_rest_endpoint" {
  type        = string
  description = "Schema Registry REST endpoint"
}

variable "schema_registry_api_key" {
  type        = string
  description = "Schema Registry API Key"
}

variable "schema_registry_api_secret" {
  type        = string
  description = "Schema Registry API Secret"
}

variable "subjects" {
  type = list(object({
    subject_name = string  # e.g., "sensor-telemetry-value"
    file_path    = string  # path to .avro file, e.g., "${module.assets.avro_path}/sensor-telemetry.avro"
  }))
  description = "List of AVRO subjects to register"
}
