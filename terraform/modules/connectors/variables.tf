variable "environment_id" {
  type        = string
  description = "ID del environment en Confluent Cloud"
}

variable "kafka_cluster_id" {
  type        = string
  description = "ID del Kafka cluster"
}

variable "mysql_admin" {
  type        = string
}

variable "mysql_password" {
  type        = string
  sensitive   = true
}

variable "mysql_host" {
  type        = string
}

variable "connectors" {
  type = list(object({
    name             = string
    config           = map(string)
  }))
  description = "Lista de conectores a crear"
}
