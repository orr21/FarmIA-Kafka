variable "environment_id" {
  type        = string
  description = "ID del environment en Confluent Cloud donde buscar el Schema Registry"
}

variable "schema_registry_cluster_id" {
  type        = string
  description = "ID del Schema Registry"
}

variable "schema_registry_rest_endpoint" {
  type        = string
  description = "REST endpoint del Schema Registry"
}

variable "schema_registry_api_key" {
  type        = string
  description = "API Key para Schema Registry"
}

variable "schema_registry_api_secret" {
  type        = string
  description = "API Secret para Schema Registry"
}

variable "subjects" {
  type = list(object({
    subject_name = string  # p.ej. "sensor-telemetry-value"
    file_path    = string  # ruta al .avro, p.ej. "${module.assets.avro_path}/sensor-telemetry.avro"
  }))
  description = "Lista de subjects AVRO a registrar"
}
