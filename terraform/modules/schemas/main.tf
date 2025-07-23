terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "=2.34.0"
    }
  }
}

resource "confluent_schema" "this" {

  for_each = { for s in var.subjects : s.subject_name => s }

  schema_registry_cluster {
    id = var.schema_registry_cluster_id
  }

  rest_endpoint = var.schema_registry_rest_endpoint
  subject_name  = each.value.subject_name
  format        = "AVRO"
  schema        = file(each.value.file_path)

  credentials {
    key    = var.schema_registry_api_key
    secret = var.schema_registry_api_secret
  }
}
