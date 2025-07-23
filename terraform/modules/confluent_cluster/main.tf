terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.34.0"
    }
  }
}

resource "confluent_kafka_cluster" "this" {
  display_name = var.cluster_name
  cloud        = var.cloud
  region       = var.region
  availability = var.availability

  environment {
    id = var.environment_id
  }

  standard {}
}

resource "confluent_service_account" "app_manager" {
  display_name = "${var.cluster_name}-manager"
  description  = "Service account to manage Kafka cluster ${var.cluster_name}"
}

resource "confluent_role_binding" "app_manager_binding" {
  principal   = "User:${confluent_service_account.app_manager.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.this.rbac_crn
}

resource "confluent_api_key" "kafka" {
  display_name = "${var.cluster_name}-kafka-key"
  description  = "API Key for Kafka cluster ${var.cluster_name}"

  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.this.id
    api_version = confluent_kafka_cluster.this.api_version
    kind        = confluent_kafka_cluster.this.kind

    environment {
      id = var.environment_id
    }
  }

  depends_on = [
    confluent_role_binding.app_manager_binding
  ]
}

data "confluent_schema_registry_cluster" "this" {
  environment {
    id = var.environment_id
  }

  depends_on = [
    confluent_kafka_cluster.this
  ]
}

resource "confluent_service_account" "apikey_owner" {
  display_name = "sr-apikey-owner-${var.environment_id}"
  description  = "Owner for Schema Registry API Key"
}

resource "confluent_role_binding" "env-manager-data-steward" {
  principal   = "User:${confluent_service_account.apikey_owner.id}"
  role_name   = "DataSteward"
  crn_pattern = var.environment_rn
}

resource "confluent_api_key" "registry_key" {
  display_name = "sr-key-${var.environment_id}"
  description  = "API Key for Schema Registry in env ${var.environment_id}"

  owner {
    id          = confluent_service_account.apikey_owner.id
    api_version = confluent_service_account.apikey_owner.api_version
    kind        = confluent_service_account.apikey_owner.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.this.id
    api_version = data.confluent_schema_registry_cluster.this.api_version
    kind        = data.confluent_schema_registry_cluster.this.kind

    environment {
      id = var.environment_id
    }
  }
}
