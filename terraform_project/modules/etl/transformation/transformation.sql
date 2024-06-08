-- 1. Eliminación de Duplicados (Vista)
CREATE OR REPLACE VIEW processing.aemet_data_clean_view AS
SELECT DISTINCT
    Fecha,
    Estacion,
    Provincia,
    Temperatura_Media_C,
    Temperatura_Maxima_C,
    Temperatura_Minima_C,
    Precipitacion_mm,
    Humedad_Relativa_Media,
    Presion_Maxima_hPa,
    Presion_Minima_hPa,
    Velocidad_Media_Viento_ms,
    Racha_Maxima_Viento_ms
FROM
    staging.aemet_data;

-- 2. Validación y Limpieza (Vista)
CREATE OR REPLACE VIEW processing.aemet_data_clean_validated_view AS
SELECT *
FROM
    processing.aemet_data_clean_view
WHERE
    Temperatura_Media_C IS NOT NULL
    AND Temperatura_Maxima_C IS NOT NULL
    AND Temperatura_Minima_C IS NOT NULL
    AND Temperatura_Media_C >= 0
    AND Temperatura_Maxima_C >= 0
    AND Temperatura_Minima_C >= 0;

-- 3. Agregación y Cálculo (Tabla en Reporting)
CREATE OR REPLACE TABLE reporting.aemet_data_aggregated AS
SELECT
    Provincia,
    Fecha,
    AVG(Temperatura_Media_C) AS Avg_Temperatura_Media_C,
    AVG(Temperatura_Maxima_C) AS Avg_Temperatura_Maxima_C,
    AVG(Temperatura_Minima_C) AS Avg_Temperatura_Minima_C,
    SUM(Precipitacion_mm) AS Total_Precipitacion_mm,
    AVG(Humedad_Relativa_Media) AS Avg_Humedad_Relativa_Media,
    AVG(Presion_Maxima_hPa) AS Avg_Presion_Maxima_hPa,
    AVG(Presion_Minima_hPa) AS Avg_Presion_Minima_hPa,
    AVG(Velocidad_Media_Viento_ms) AS Avg_Velocidad_Media_Viento_ms,
    MAX(Racha_Maxima_Viento_ms) AS Max_Racha_Maxima_Viento_ms
FROM
    processing.aemet_data_clean_validated_view
GROUP BY
    Provincia,
    Fecha;

