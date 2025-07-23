terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.34.0"
    }
  }
}

resource "confluent_connector" "this" {

  for_each = { for c in var.connectors : c.name => c }

  environment {
    id = var.environment_id
  }

  kafka_cluster {
    id = var.kafka_cluster_id
  }

  config_nonsensitive = each.value.config
}
