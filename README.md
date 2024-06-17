# Altostratus ETL Data Pipeline

Plan detallado de implementación de la arquitectura de extracción, carga y transformación (ELT) desde la API de AEMET.

![Dashboard Visualization](documentation/images/altostratus-data-prj-dashboard.png)



### Pasos para Implementar la Arquitectura ELT

1. **Configurar Cloud Scheduler para Iniciar el Orchestrator**
2. **Configurar Workflows en Google Cloud para Orquestación**
3. **Crear el Connector para Extraer Datos de la API de AEMET**
4. **Configurar BigQuery para Staging, Processing y Reporting**
5. **Configurar Dataform para Transformación de Datos**
6. **Configurar Looker Studio para Visualización de Datos**

## GCP Architecture

![subject](documentation/images/gcp_structure.png)

## Project Structure

```css
terraform_project/
.
├── etl
│   ├── connector
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── app
│   │       ├── error_handling.py
│   │       ├── main.py
│   │       └── requirements.txt
│   └── transformation
│       ├── main.tf
│       ├── transformation.sql
│       └── variables.tf
├── bigquery
│   └──  main.tf
│   └──  variables.tf
├── cloud_scheduler
│   └──  main.tf
│   └──  variables.tf
└── scripts
    ├── run_etl.sh
    └── undo_etl.sh
```
