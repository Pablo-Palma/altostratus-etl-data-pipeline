# Self Healing

Autosanación, capacidad de sistemas de detectar y corregir fallos de forma autónoma.

## 1. Partimos datos con fechas 24 y 25 de junio cargados en nuestro staging dataset.

```
PPR$ bq query --use_legacy_sql=false 'SELECT * FROM `altostratus-dataretobootcaamp.staging.aemet_data`'
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
|   Fecha    |    Estacion    | Provincia | Temperatura_Media_C | Temperatura_Maxima_C | Temperatura_Minima_C | Precipitacion_mm | Humedad_Relativa_Media | Presion_Maxima_hPa | Presion_Minima_hPa | Velocidad_Media_Viento_ms | Racha_Maxima_Viento_ms |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
| 2024-05-24 | MADRID, RETIRO | MADRID    |                20.0 |                 27.6 |                 12.5 |              0.0 |                   38.0 |              939.5 |              936.6 |                       1.9 |                    9.4 |
| 2024-05-25 | MADRID, RETIRO | MADRID    |                21.5 |                 29.2 |                 13.8 |              0.0 |                   27.0 |              940.3 |              937.8 |                       3.1 |                   13.3 |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
```
## 2. Simulamos un fallo en la conexión añadiendo un caracter al url.

Observamos que se almacena en nuestro dataset "failed_request".

```
PPR$ curl https://us-central1-altostratus-dataretobootcaamp.cloudfunctions.net/aemet-connector
{"error":"No connection adapters were found for 'Yhttps://opendata.aemet.es/opendata/api/valores/climatologicos/diarios/datos/fechaini/2024-05-26T00:00:00UTC/fechafin/2024-05-27T23:59:59UTC/estacion/3195'"}
PPR$ bq query --use_legacy_sql=false 'SELECT * FROM `altostratus-dataretobootcaamp.staging.failed_requests`'
+------------------------+------------------------+----------+
|      FechaInicio       |        FechaFin        | Estacion |
+------------------------+------------------------+----------+
| 2024-05-26T00:00:00UTC | 2024-05-27T23:59:59UTC | 3195     |
+------------------------+------------------------+----------+
```

PPR$ bq query --use_legacy_sql=false 'SELECT * FROM `altostratus-dataretobootcaamp.staging.aemet_data`'
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
|   Fecha    |    Estacion    | Provincia | Temperatura_Media_C | Temperatura_Maxima_C | Temperatura_Minima_C | Precipitacion_mm | Humedad_Relativa_Media | Presion_Maxima_hPa | Presion_Minima_hPa | Velocidad_Media_Viento_ms | Racha_Maxima_Viento_ms |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
| 2024-05-24 | MADRID, RETIRO | MADRID    |                20.0 |                 27.6 |                 12.5 |              0.0 |                   38.0 |              939.5 |              936.6 |                       1.9 |                    9.4 |
| 2024-05-25 | MADRID, RETIRO | MADRID    |                21.5 |                 29.2 |                 13.8 |              0.0 |                   27.0 |              940.3 |              937.8 |                       3.1 |                   13.3 |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+

## 3. Recomponemos la url para simular la recuperación de la web aemet, y comprobar que automáticamente se recupera la carga.

```
PPR$ bq query --use_legacy_sql=false 'SELECT * FROM `altostratus-dataretobootcaamp.staging.aemet_data`'
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
PPR$ curl https://us-central1-altostratus-dataretobootcaamp.cloudfunctions.net/aemet-connector
{"message":"Data loaded successfully"}
PPR$
PPR$ bq query --use_legacy_sql=false 'SELECT * FROM `altostratus-dataretobootcaamp.staging.aemet_data`'
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
|   Fecha    |    Estacion    | Provincia | Temperatura_Media_C | Temperatura_Maxima_C | Temperatura_Minima_C | Precipitacion_mm | Humedad_Relativa_Media | Presion_Maxima_hPa | Presion_Minima_hPa | Velocidad_Media_Viento_ms | Racha_Maxima_Viento_ms |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
| 2024-05-24 | MADRID, RETIRO | MADRID    |                20.0 |                 27.6 |                 12.5 |              0.0 |                   38.0 |              939.5 |              936.6 |                       1.9 |                    9.4 |
| 2024-05-25 | MADRID, RETIRO | MADRID    |                21.5 |                 29.2 |                 13.8 |              0.0 |                   27.0 |              940.3 |              937.8 |                       3.1 |                   13.3 |
| 2024-05-26 | MADRID, RETIRO | MADRID    |                21.7 |                 29.6 |                 13.8 |              0.0 |                   31.0 |              940.9 |              937.4 |                       2.8 |                   11.4 |
| 2024-05-27 | MADRID, RETIRO | MADRID    |                23.2 |                 30.3 |                 16.2 |              0.0 |                   35.0 |              941.1 |              938.1 |                       1.1 |                   10.8 |
| 2024-05-28 | MADRID, RETIRO | MADRID    |                23.4 |                 30.4 |                 16.5 |              0.0 |                   41.0 |              942.9 |              939.3 |                       1.7 |                    9.2 |
| 2024-05-29 | MADRID, RETIRO | MADRID    |                26.3 |                 33.5 |                 19.1 |              0.0 |                   32.0 |              941.0 |              936.5 |                       1.1 |                    9.4 |
+------------+----------------+-----------+---------------------+----------------------+----------------------+------------------+------------------------+--------------------+--------------------+---------------------------+------------------------+
```
