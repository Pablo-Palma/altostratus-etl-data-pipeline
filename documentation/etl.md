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

### Verificación de los Datos

El comando que has usado (`bq head -n 10 altostratus-dataretobootcaamp:reporting.aemet_data_aggregated`) muestra que los datos en `reporting` están bien formateados y contienen las métricas agregadas necesarias:

```sh
bq head -n 10 altostratus-dataretobootcaamp:reporting.aemet_data_aggregated
```

# Comands:

1. **Listar datasets:**
   ```sh
   bq ls --project_id=altostratus-dataretobootcaamp
   ```

2. **Supongamos que el dataset es `staging`, listar tablas:**
   ```sh
   bq ls altostratus-dataretobootcaamp:staging
   ```

3. **Supongamos que la tabla es `aemet_data`, listar los primeros 10 registros:**
   ```sh
   bq head -n 10 altostratus-dataretobootcaamp:staging.aemet_data
   ```

## Ejecutar el Script de Transformación en BigQuery:

```
bq query --use_legacy_sql=false < transformation/transformation.sql
```
