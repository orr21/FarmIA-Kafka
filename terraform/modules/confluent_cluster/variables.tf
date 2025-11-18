variable "environment_id" {
  type        = string
  description = "Confluent Cloud environment ID"
}

variable "environment_rn" {
  type        = string
  description = "Confluent Cloud environment Resource Name"
}

variable "cluster_name" {
  type        = string
  description = "Kafka Cluster name"
}

variable "cloud" {
  type        = string
  default     = "AZURE"
  description = "Cloud provider (AZURE, AWS, GCP)"
}

variable "region" {
  type        = string
  description = "Region where to deploy the Kafka Cluster"
}

variable "availability" {
  type        = string
  default     = "SINGLE_ZONE"
  description = "Kafka Cluster availability"
}