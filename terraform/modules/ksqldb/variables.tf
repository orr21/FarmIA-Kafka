variable "confluent_api_key" {
  type = string
}

variable "confluent_api_secret" {
  type = string
}

variable "environment_id" {
  type = string
}

variable "kafka_cluster_id" {
  type = string
}

variable "cluster_rbac_crn" {
  type = string
}

variable "ksql_scripts_path" {
  type = string
  description = "Ruta al directorio con los JSON/SQL de ksql (ej. modules/assets/sql)"
}