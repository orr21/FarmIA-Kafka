variable "cluster_id" {
  type        = string
  description = "ID del Kafka cluster"
}

variable "rest_endpoint" {
  type        = string
  description = "REST endpoint del Kafka cluster"
}

variable "credentials" {
  type = object({
    key    = string
    secret = string
  })
  description = "Credenciales API Key/Secret para Confluent Kafka"
}

variable "topics" {
  type = list(object({
    name       = string
    partitions = number
    config     = map(string)
  }))
  description = "Lista de topics a crear"
}
