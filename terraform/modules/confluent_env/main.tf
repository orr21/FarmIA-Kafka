terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.34.0"
    }
  }
}

resource "confluent_environment" "this" {
  display_name = var.environment_name

  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_service_account" "env_manager" {
  display_name = "${var.environment_name}-manager"
  description  = "Service account to manage environment ${var.environment_name}"
}

resource "confluent_role_binding" "env_manager_binding" {
  principal   = "User:${confluent_service_account.env_manager.id}"
  role_name   = "DataSteward"
  crn_pattern = confluent_environment.this.resource_name
}
