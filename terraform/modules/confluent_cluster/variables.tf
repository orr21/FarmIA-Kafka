variable "environment_id" {
  type        = string
  description = "ID del environment en Confluent Cloud"
}

variable "environment_rn" {
  type        = string
  description = "Resource Name del environment en Confluent Cloud"
}

variable "cluster_name" {
  type        = string
  description = "Nombre del Kafka Cluster"
}

variable "cloud" {
  type        = string
  default     = "AZURE"
  description = "Proveedor cloud (AZURE, AWS, GCP)"
}

variable "region" {
  type        = string
  description = "Región donde desplegar el Kafka Cluster"
}

variable "availability" {
  type        = string
  default     = "SINGLE_ZONE"
  description = "Disponibilidad del Kafka Cluster"
}