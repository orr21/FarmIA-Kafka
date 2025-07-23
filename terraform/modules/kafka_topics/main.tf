terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "=2.34.0"
    }
  }
}

resource "confluent_kafka_topic" "this" {
  for_each = { for t in var.topics : t.name => t }

  kafka_cluster {
    id = var.cluster_id
  }
  topic_name    = each.value.name
  rest_endpoint = var.rest_endpoint

  credentials {
    key    = var.credentials.key
    secret = var.credentials.secret
  }

  partitions_count = each.value.partitions
}
