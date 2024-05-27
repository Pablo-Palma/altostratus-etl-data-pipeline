# Altostratus_Data-Reto_Bootcamp_42

Plan detallado de implementación de la arquitectura de extracción, carga y transformación (ELT) desde la API de AEMET.

### Pasos para Implementar la Arquitectura ELT

1. **Configurar Cloud Scheduler para Iniciar el Orchestrator**
2. **Configurar Workflows en Google Cloud para Orquestación**
3. **Crear el Connector para Extraer Datos de la API de AEMET**
4. **Configurar BigQuery para Staging, Processing y Reporting**
5. **Configurar Dataform para Transformación de Datos**
6. **Configurar Looker Studio para Visualización de Datos**

```css
terraform_project/
├── main.tf
├── outputs.tf
├── variables.tf
├── terraform.tfvars
├── modules/
│   ├── iam_orchestrator/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── cloud_scheduler/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── workflows/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── connector/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── bigquery/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── transformation/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── looker_studio/
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
```
