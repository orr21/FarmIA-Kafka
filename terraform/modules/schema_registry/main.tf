terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.34.0"
    }
  }
}

data "confluent_schema_registry_cluster" "this" {
  environment {
    id = var.environment_id
  }
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

resource "confluent_service_account" "apikey_owner" {
  display_name = "sr-apikey-owner-${var.environment_id}"
  description  = "Owner for Schema Registry API Key"
}
