terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.34.0"
    }
  }
}


resource "confluent_ksql_cluster" "this" {
  display_name = "ksql-${var.environment_id}"
  csu          = 1

  kafka_cluster {
    id = var.kafka_cluster_id
  }

  credential_identity {
    id = confluent_service_account.ksql_sa.id
  }

  environment {
    id = var.environment_id
  }
}

data "confluent_schema_registry_cluster" "this" {
  environment {
    id = var.environment_id
  }
}

resource "confluent_service_account" "ksql_sa" {
  display_name = "ksql-sa-${var.environment_id}"
  description  = "Service account for ksqlDB ${var.environment_id}"
}

resource "confluent_role_binding" "ksql_sa-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.ksql_sa.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = var.cluster_rbac_crn
}

resource "confluent_role_binding" "ksql_sa-schema-registry-resource-owner" {
  principal   = "User:${confluent_service_account.ksql_sa.id}"
  role_name   = "ResourceOwner"
  crn_pattern = format("%s/%s", data.confluent_schema_registry_cluster.this.resource_name, "subject=*")
}

resource "confluent_role_binding" "ksql_sa-topic-owner" {
  principal   = "User:${confluent_service_account.ksql_sa.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${var.cluster_rbac_crn}/kafka=${var.kafka_cluster_id}/topic=*"
}

resource "confluent_role_binding" "ksql_sa-group-owner" {
  principal   = "User:${confluent_service_account.ksql_sa.id}"
  role_name   = "ResourceOwner"
  crn_pattern = "${var.cluster_rbac_crn}/kafka=${var.kafka_cluster_id}/group=*"
}

resource "confluent_api_key" "ksql_key" {
  display_name = "ksql-key-${var.environment_id}"
  description  = "API Key for ksqlDB ${var.environment_id}"
  owner {
    id          = confluent_service_account.ksql_sa.id
    api_version = confluent_service_account.ksql_sa.api_version
    kind        = confluent_service_account.ksql_sa.kind
  }

  managed_resource {
    id          = confluent_ksql_cluster.this.id
    api_version = confluent_ksql_cluster.this.api_version
    kind        = confluent_ksql_cluster.this.kind

    environment {
      id = var.environment_id
    }
  }
}

locals {
  scripts = fileset(var.ksql_scripts_path, "*.json")
}

resource "null_resource" "create_ksql_stream_sensor_data" {
  provisioner "local-exec" {
    command = <<EOT
    set -e

    LOG_FILE="./logs/ksql-sensor_data.log"

    curl -u ${confluent_api_key.ksql_key.id}:${confluent_api_key.ksql_key.secret} \
      -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
      -X POST ${confluent_ksql_cluster.this.rest_endpoint}/ksql \
      -d @${var.ksql_scripts_path}/sensor_data.json \
      2>&1 | tee -a $LOG_FILE
    EOT
  }

  depends_on = [
    confluent_ksql_cluster.this,
    confluent_api_key.ksql_key
  ]
}

resource "null_resource" "create_ksql_stream_sensor_alerts" {
  provisioner "local-exec" {
    command = <<EOT
    set -e

    LOG_FILE="./logs/ksql-sensor_alerts.log"

    curl -u ${confluent_api_key.ksql_key.id}:${confluent_api_key.ksql_key.secret} \
      -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
      -X POST ${confluent_ksql_cluster.this.rest_endpoint}/ksql \
      -d @${var.ksql_scripts_path}/sensor_alerts.json \
      2>&1 | tee -a $LOG_FILE
    EOT
  }

  depends_on = [
    null_resource.create_ksql_stream_sensor_data,
  ]
}

resource "null_resource" "create_ksql_stream_sales_data" {
  provisioner "local-exec" {
    command = <<EOT
    set -e

    LOG_FILE="./logs/ksql-sales_data.log"

    curl -u ${confluent_api_key.ksql_key.id}:${confluent_api_key.ksql_key.secret} \
      -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
      -X POST ${confluent_ksql_cluster.this.rest_endpoint}/ksql \
      -d @${var.ksql_scripts_path}/sales_data.json \
      2>&1 | tee -a $LOG_FILE
    EOT
  }

  depends_on = [
    null_resource.create_ksql_stream_sensor_alerts,
  ]
}

resource "null_resource" "create_ksql_table_sales_summary" {
  provisioner "local-exec" {
    command = <<EOT
    set -e

    LOG_FILE="./logs/ksql-sales_summary.log"

    curl -u ${confluent_api_key.ksql_key.id}:${confluent_api_key.ksql_key.secret} \
      -H "Content-Type: application/vnd.ksql.v1+json; charset=utf-8" \
      -X POST ${confluent_ksql_cluster.this.rest_endpoint}/ksql \
      -d @${var.ksql_scripts_path}/sales_summary.json \
      2>&1 | tee -a $LOG_FILE
    EOT
  }

  depends_on = [
    null_resource.create_ksql_stream_sales_data,
  ]
}
