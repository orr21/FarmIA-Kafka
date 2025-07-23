variable "subscription" {
  type        = string
  description = "ID de suscripción Azure"
}

variable "location" {
  type        = string
  description = "Región Azure"
}

variable "my_ip" {
  type        = string
  description = "Tu IP pública para reglas de firewall"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Ruta a tu clave pública SSH"
}

variable "mysql_admin" {
  type        = string
  description = "Usuario administrador MySQL"
}

variable "mysql_password" {
  type        = string
  sensitive   = true
  description = "Password administrador MySQL"
}

variable "confluent_api_key" {
  type        = string
  description = "API Key de Confluent Cloud"
}

variable "confluent_api_secret" {
  type        = string
  sensitive   = true
  description = "API Secret de Confluent Cloud"
}

variable "environment_name" {
  type        = string
  description = "Nombre del Environment en Confluent"
}

variable "cluster_name" {
  type        = string
  description = "Nombre del Kafka Cluster"
}

variable "azure_region" {
  type        = string
  description = "Región para el Kafka Cluster (p.ej. AZURE región)"
}

variable "availability" {
  type        = string
  default     = "SINGLE_ZONE"
  description = "Disponibilidad del Kafka Cluster"
}
