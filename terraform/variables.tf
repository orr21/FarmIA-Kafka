variable "subscription" {
  type        = string
  description = "Azure subscription ID"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "my_ip" {
  type        = string
  description = "Your public IP for firewall rules"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "mysql_admin" {
  type        = string
  description = "MySQL administrator user"
}

variable "mysql_password" {
  type        = string
  sensitive   = true
  description = "MySQL administrator password"
}

variable "confluent_api_key" {
  type        = string
  description = "Confluent Cloud API Key"
}

variable "confluent_api_secret" {
  type        = string
  sensitive   = true
  description = "Confluent Cloud API Secret"
}

variable "environment_name" {
  type        = string
  description = "Confluent Environment name"
}

variable "cluster_name" {
  type        = string
  description = "Kafka Cluster name"
}

variable "azure_region" {
  type        = string
  description = "Region for Kafka Cluster (e.g., Azure region)"
}

variable "availability" {
  type        = string
  default     = "SINGLE_ZONE"
  description = "Kafka Cluster availability"
}
