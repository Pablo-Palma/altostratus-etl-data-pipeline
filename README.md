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
    
### Idempotencia
La idempotencia es un principio de diseño que asegura que múltiples invocaciones de una operación bajo las mismas condiciones producen el mismo resultado sin efectos adicionales. En el contexto de un conector ETL, asegura que al ejecutarse repetidas veces, el proceso no generará datos duplicados, incluso si se invoca varias veces el mismo día.

El conector está diseñado para ser idempotente. Esto se logra mediante una serie de controles y verificaciones que aseguran que solo se carguen datos nuevos o faltantes en la base de datos, sin duplicar entradas existentes. A continuación, se detallan los pasos y mecanismos utilizados:

1. **Verificación de Datos Existentes:**
   - Antes de insertar datos en BigQuery, el conector verifica si ya existen en la tabla destino. Esto se hace mediante una consulta SQL que busca registros por fecha y estación.
   ```python
   def check_data_exists(client, table_id, date, station):
       query = f"""
       SELECT COUNT(*) as count
       FROM `{table_id}`
       WHERE Fecha = '{date}' AND Estacion = '{station}'
       """
       query_job = client.query(query)
       results = query_job.result()
       for row in results:
           if row.count > 0:
               return True
       return False
   ```

2. **Procesamiento Condicional de Datos:**
   - Solo los datos que no existen actualmente en la base de datos son procesados y cargados. Esto evita duplicados y asegura que cada ejecución del conector, incluso repetida en el mismo día, no altere los resultados de las cargas anteriores.
   ```python
   for row in data:
       if not check_data_exists(client, table_id, row['Fecha'], row['Estacion']):
           unique_data.append(row)

   if unique_data:
       errors = client.insert_rows_json(table_id, unique_data)
       if errors:
           raise Exception(f"Failed to insert rows: {errors}")
   ```

3. **Manejo de Excepciones y Errores de Conectividad:**
   - Cualquier fallo en la obtención de datos o en la respuesta de la API resulta en la captura de estos incidentes sin reintentar automáticamente la carga, lo que podría llevar a intentos duplicados de inserción.
   ```python
   except requests.exceptions.RequestException as e:
       print(f"Exception occurred for station {station_id}, logging failed request: {e}")
       failed_stations.append(station_id)
   ```

#### Beneficios de la Idempotencia
Implementar la idempotencia en el conector ofrece múltiples beneficios, incluyendo:
- **Consistencia de Datos**: Asegura que los datos sean consistentes y confiables, libres de duplicaciones no deseadas.
- **Robustez Operativa**: Mejora la robustez del sistema al manejar fallos y reinvocaciones sin introducir anomalías en los datos.
- **Optimización de Recursos**: Reduce el uso innecesario de recursos al evitar procesar y almacenar datos que ya están presentes.   
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

