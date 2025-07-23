terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "=2.34.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription
}

provider "confluent" {
  alias            = "cloud"
  cloud_api_key    = var.confluent_api_key
  cloud_api_secret = var.confluent_api_secret
}

resource "azurerm_resource_group" "main" {
  name     = "kafka-realtime-rg"
  location = var.location
}

resource "azurerm_virtual_network" "main" {
  name                = "farmia-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "farmia-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "azure_core" {
  source              = "./modules/azure_core"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.main.id
  my_ip               = var.my_ip
  ssh_public_key_path = var.ssh_public_key_path
  mysql_admin         = var.mysql_admin
  mysql_password      = var.mysql_password
}

module "confluent_env" {
  source               = "./modules/confluent_env"
  providers = {
    confluent = confluent.cloud
  }
  environment_name     = var.environment_name
}

module "confluent_cluster" {
  source               = "./modules/confluent_cluster"
  providers = {
    confluent = confluent.cloud
  }
  cluster_name         = var.cluster_name
  cloud                = "AZURE"
  region               = var.azure_region
  availability         = var.availability

  environment_id       = module.confluent_env.environment_id
  environment_rn       = module.confluent_env.environment_rn 
}

module "schemas" {
  source                        = "./modules/schemas"
  providers = {
    confluent = confluent.cloud
  }
  environment_id                = module.confluent_env.environment_id

  schema_registry_cluster_id    = module.confluent_cluster.schema_registry_cluster_id
  schema_registry_rest_endpoint = module.confluent_cluster.schema_registry_rest_endpoint
  schema_registry_api_key       = module.confluent_cluster.schema_registry_api_key
  schema_registry_api_secret    = module.confluent_cluster.schema_registry_api_secret

  subjects = [
    {
      subject_name = "sensor-telemetry-value"
      file_path    = "./modules/assets/avro_schemas/sensor-telemetry.avro"
    },
    {
      subject_name = "sales-transactions-value"
      file_path    = "./modules/assets/avro_schemas/transactions.avro"
    },
    {
      subject_name = "_transactions-value"
      file_path    = "./modules/assets/avro_schemas/transactions.avro"
    },
  ]
}

module "kafka_topics" {
  source        = "./modules/kafka_topics"
  providers = {
    confluent = confluent.cloud
  }
  cluster_id    = module.confluent_cluster.cluster_id
  rest_endpoint = module.confluent_cluster.rest_endpoint
  credentials = {
    key    = module.confluent_cluster.api_key
    secret = module.confluent_cluster.api_secret
  }
  topics = [
    { name = "sensor-telemetry",   partitions = 6, config = {} },
    { name = "sensor-alerts",       partitions = 6, config = {} },
    { name = "sales-transactions", partitions = 6, config = {} },
    { name = "sales-summary",      partitions = 6, config = {} },
    { name = "_transactions",      partitions = 6, config = {} }
  ]
}

module "connectors" {
  source                     = "./modules/connectors"
  providers = {
    confluent = confluent.cloud
  }

  environment_id             = module.confluent_env.environment_id
  kafka_cluster_id           = module.confluent_cluster.cluster_id

  mysql_admin                = var.mysql_admin
  mysql_password             = var.mysql_password
  mysql_host                 = module.azure_core.vm_public_ip

  depends_on                 = [module.kafka_topics, module.schemas]

  connectors = [
    {
      "name"                          = "datagen-sensor-telemetry"
      config = {
        "name"                          = "datagen-sensor-telemetry"
        "connector.class"               = "DatagenSource"
        "kafka.topic"                   = "sensor-telemetry"
        "output.data.format"            = "AVRO"
        "schema.string"                 = file("./modules/assets/avro_schemas/sensor-telemetry.avro")
        "schema.keyfield"               = "sensor_id"
        "kafka.auth.mode"               = "SERVICE_ACCOUNT"
        "kafka.service.account.id"      = module.confluent_cluster.service_account_id
        "tasks.max"                     = "1"
        "max.interval"                  = "1000"
        "iterations"                    = "1000"
      }
    },
    {
      "name"                          = "datagen-sales-transactions"
      config = {
        "name"                          = "datagen-sales-transactions"
        "connector.class"               = "DatagenSource"
        "kafka.topic"                   = "_transactions"
        "output.data.format"            = "AVRO"
        "schema.string"                 = file("./modules/assets/avro_schemas/transactions.avro")
        "schema.keyfield"               = "transaction_id"
        "kafka.auth.mode"               = "SERVICE_ACCOUNT"
        "kafka.service.account.id"      = module.confluent_cluster.service_account_id
        "tasks.max"                     = "1"
        "max.interval"                  = "1000"
        "iterations"                    = "1000"
      }
    },
    {
      "name"                          = "sink-mysql-transactions"
      config = {
        "name"                          = "sink-mysql-transactions"
        "connector.class"               = "MySqlSink"
        "topics"                        = "_transactions"
        "input.data.format"             = "AVRO"
        "connection.host"               = module.azure_core.vm_public_ip
        "connection.port"               = "3306"
        "connection.user"               = var.mysql_admin
        "connection.password"           = var.mysql_password
        "db.name"                       = "farmia"
        "table.name.format"             = "transactions"
        "kafka.auth.mode"               = "SERVICE_ACCOUNT"
        "kafka.service.account.id"      = module.confluent_cluster.service_account_id
        "insert.mode"                   = "INSERT"
        "tasks.max"                     = "1"
      }
    },
    {
      "name"                          = "source-mysql-transactions"
      config = {
        "name"                          = "source-mysql-transactions"
        "connector.class"               = "MySqlSource"
        "tasks.max"                     = "1"

        "connection.host"               = module.azure_core.vm_public_ip
        "connection.port"               = "3306"
        "connection.user"               = var.mysql_admin
        "connection.password"           = var.mysql_password
        "db.name"                       = "farmia"
        "table.whitelist"               = "transactions"
        "mode"                          = "incrementing"
        "incrementing.column.name"      = "timestamp"

        "kafka.auth.mode"               = "SERVICE_ACCOUNT"
        "kafka.service.account.id"      = module.confluent_cluster.service_account_id

        "topic.prefix"                  = "sales-"
        "output.data.format"            = "AVRO"
        "key.converter.schemas.enable"  = "AvroConverter"
        "value.converter"               = "AvroConverter"

        "transforms"                    = "ValueToKey, ExtractField",
        "transforms.ValueToKey.type"    = "org.apache.kafka.connect.transforms.ValueToKey",
        "transforms.ValueToKey.fields"  = "transaction_id"
        "transforms.ExtractField.type"  = "org.apache.kafka.connect.transforms.ExtractField$Key",
        "transforms.ExtractField.field" = "transaction_id"

        "poll.interval.ms"              = "1000"
      }
    },
  ]
}

module "ksqldb" {
  source               = "./modules/ksqldb"
  providers = {
    confluent = confluent.cloud
  }

  confluent_api_key    = var.confluent_api_key
  confluent_api_secret = var.confluent_api_secret

  environment_id       = module.confluent_env.environment_id
  kafka_cluster_id     = module.confluent_cluster.cluster_id
  cluster_rbac_crn     = module.confluent_cluster.cluster_rbac_crn

  ksql_scripts_path    = "modules/assets/ksql"

  depends_on                 = [module.kafka_topics]
}
