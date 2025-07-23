# FarmIA – Kafka y Procesamiento en Tiempo Real

Este proyecto tiene como objetivo construir un pipeline de procesamiento en tiempo real para FarmIA utilizando Apache Kafka y su ecosistema. El sistema permite integrar datos de sensores agrícolas (IoT) y transacciones de ventas en línea, generando información valiosa para la toma de decisiones.

## Requisitos

Debes tener **Terraform instalado** en tu sistema para desplegar la infraestructura.  
Puedes descargarlo desde: [https://www.terraform.io/downloads.html](https://www.terraform.io/downloads.html)

### Versiones de Providers

Este proyecto utiliza las siguientes versiones de providers:

````hcl
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

## Objetivo de la Tarea

Construir una solución de streaming basada en Kafka que:

1. Procese datos de sensores en tiempo real para detectar condiciones anómalas.
2. Procese datos de transacciones en tiempo real para generar resumenes agregados minuto a minuto.
3. Use Kafka Streams o KSQLDB para generar:
   - Alertas ante anomalías de sensores.
   - Resúmenes de ventas por categoría de producto cada minuto.

---

## Estructura del Repositorio

```plaintext
├── LICENSE
├── README.md                    # Este archivo
└── terraform/
    ├── logs/                    # Logs de ejecución de las queries KSQL
    │   ├── ksql-sales_data.log
    │   ├── ksql-sales_summary.log
    │   ├── ksql-sensor_alerts.log
    │   └── ksql-sensor_data.log
    ├── main.tf                  # Archivo principal de Terraform
    ├── terraform.tfvars.example# Plantilla de configuración
    ├── variables.tf            # Definición de variables globales
    ├── modules/
    │   ├── assets/
    │   │   ├── avro_schemas/   # Schemas AVRO (sensor y transacciones)
    │   │   ├── ksql/           # Queries KSQL en formato JSON
    │   │   └── scripts/        # Scripts auxiliares como startup.sh
    │   ├── azure_core/         # Infraestructura en Azure para la base de datos MySQL
    │   ├── confluent_cluster/  # Configuración del clúster Kafka
    │   ├── confluent_env/      # Entorno de variables Confluent
    │   ├── connectors/         # Definición de conectores Kafka Connect
    │   ├── kafka_topics/       # Declaración de los topics Kafka
    │   ├── ksqldb/             # Configuración de KSQLDB
    │   ├── schema_registry/    # Registro de schemas
    │   └── schemas/            # Gestión de schemas vía Terraform
````

## Setup del Entorno

1. Copia y edita las variables necesarias:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Ajusta las variables en `terraform.tfvars` según tu entorno.

3. Aplica la infraestructura:
   ```bash
   cd terraform
   terraform apply -auto-approve
   ```

---

## Kafka Topics

Los siguientes topics son creados automáticamente y usados durante el flujo de procesamiento:

- `_transacions`: simula la llegada de transacciones que son almacenadas en MySQL.
- `sensor-telemetry`: recibe datos generados por sensores IoT.
- `sales-transactions`: recibe datos de ventas extraídos de MySQL.
- `sensor-alerts`: recibe las alertas generadas por anomalías en sensores.
- `sales-summary`: contiene los resúmenes de ventas por categoría.

---

## Kafka Connect

Se utilizan conectores para integrar fuentes externas a Kafka:

- **MySQL Source Connector**: 🔲 _[por definir por el alumno]_  
  Conecta la base de datos relacional y publica en `sales-transactions`.

- **MySQL Sink Connector**: 🔲 _[por definir por el alumno]_  
  Conecta la base de datos relacional y publica en `sales-transactions`.

- **Datagen Connector**: 🔲 _[por definir por el alumno]_
  - Simula datos de sensores agrícolas en el topic `sensor-telemetry`.
  - Simula datos de transacciones en el topic `_transacctions`.

La configuración de los conectores encuentran a partir de la línea 140 en `terraform/main.tf`.

---

## Kafka Streams / KSQL

El procesamiento en tiempo real se realiza mediante Kafka Streams o KSQLDB. Se implementan dos flujos principales:

1. **Detección de Anomalías (Sensores)**

   - Input: `sensor-telemetry`
   - Condiciones: temperatura > 35 °C o humedad < 20 %
   - Output: `sensor-alerts`

2. **Resumen de Ventas por Categoría**
   - Input: `sales-transactions`
   - Agrega el total de ingresos por categoría de producto cada minuto
   - Output: `sales-summary`

Las queries se encuentran en `modules/assets/ksql/`.

---

## Shutdown del Entorno

Por motivos de seguridad y control explícito, el apagado de la infraestructura debe hacerse de forma manual. Esto evita eliminaciones accidentales de recursos críticos en ambientes compartidos o en producción.

Al ejecutar terraform destroy -auto-approve saltará un error de falta de permisos.
