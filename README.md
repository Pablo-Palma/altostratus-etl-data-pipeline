# Altostratus ETL Data Pipeline

Plan detallado de implementación de la arquitectura de extracción, carga y transformación (ELT) desde la API de AEMET.

![Dashboard Visualization](documentation/images/altostratus-data-prj-dashboard.png)

### Descripción General
Este proyecto de Terraform está diseñado para automatizar el despliegue y la gestión de recursos en Google Cloud Platform para procesos ETL y otras tareas relacionadas con la gestión de datos. Incluye módulos para la creación de recursos de BigQuery, Cloud Scheduler, y funciones de Cloud, entre otros.

### Scope

| **Propiedad**   | **Detalle**                                                                                    |
|-----------------|------------------------------------------------------------------------------------------------|
| **API**         | AEMET OpenData                                                                                 |
| **URL Base**    | [opendata.aemet.es](https://opendata.aemet.es/dist/index.html#/informacion-satelite)           |
| **Endpoint**    | `/api/valores/climatologicos/diarios/datos/fechaini/{fechaIniStr}/fechafin/{fechaFinStr}/estacion/{idema}` |
| **Descripción** | Extrae datos climatológicos diarios de todas las estaciones para un rango de fechas específico.|
| **Método**      | GET                                                                                            |
| **Parámetros**  | `fechaIniStr`, `fechaFinStr`: Fecha de inicio y fin en formato YYYY-MM-DD.<br>`idema`: Código de la estación meteorológica. |
| **Uso**         | Utilizado en el Connector para extraer datos necesarios para procesamiento en Staging.         |

### Recursos de GCP Utilizados

| Recurso GCP       | Descripción                                                | Módulo Asociado    |
|-------------------|------------------------------------------------------------|--------------------|
| BigQuery          | Gestión de grandes datasets y ejecución de queries SQL.    | `bigquery`         |
| Cloud Functions   | Ejecución de código en respuesta a eventos. Contiene los scripts y las dependencias de la función. | `etl/connector/app`|
| Cloud Scheduler   | Automatización de scripts o llamadas HTTP.                 | `cloud_scheduler`  |
| Cloud Storage     | Almacena los archivos necesarios para las funciones de Cloud, como el código fuente y los archivos de configuración. | `etl/connector/app`|
| Cloud Run         | Escalable y sin servidor para contenedores.                | No especificado    |


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


### Pasos para Implementar la Arquitectura ELT


<details>
<summary><strong>ETL</strong></summary>

### Flujo de Proceso ETL

1. **Extracción (E) - Connector:**
   - La función del connector se conecta a la API de AEMET.
   - Extrae los datos meteorológicos.
   - Almacena estos datos en la tabla de `staging` en BigQuery.

2. **Transformación (T) - Transformation:**
   - **Vista para Eliminación de Duplicados:**
     - Crea la vista `processing.aemet_data_clean_view` para eliminar duplicados.
   - **Vista para Validación y Limpieza:**
     - Crea la vista `processing.aemet_data_clean_validated_view` para validar y limpiar los datos.
   - **Tabla para Agregación y Cálculo:**
     - Crea la tabla `reporting.aemet_data_aggregated` a partir de las vistas procesadas.
     - Realiza cálculos como promedio de temperatura, suma de precipitación, etc.

3. **Carga (L) - Reporting:**
   - La tabla `reporting.aemet_data_aggregated` contiene los datos finales y agregados.
   - Estos datos están listos para ser consumidos por herramientas de visualización como Looker Studio.

</details>

<details>
<summary><strong>Connector</strong></summary>
    
</details>


<details>
<summary><strong>Transformer</strong></summary>


</details>


<details>
<summary><strong>Loader</strong></summary>


</details>


<details>
<summary><strong>Machine Learning</strong></summary>


</details>

<details>
<summary><strong>Dashboard</strong></summary>


</details>

