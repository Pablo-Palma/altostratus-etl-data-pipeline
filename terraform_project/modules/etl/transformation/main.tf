provider "google" {
  project = var.project_id
  region  = var.region
}

# Tabla en Reporting
resource "google_bigquery_table" "aemet_data_aggregated" {
  dataset_id = "reporting"
  table_id   = "aemet_data_aggregated"
  deletion_protection = false
  schema = <<EOF
[
  {"name": "Provincia", "type": "STRING", "mode": "REQUIRED"},
  {"name": "Fecha", "type": "DATE", "mode": "REQUIRED"},
  {"name": "Avg_Temperatura_Media_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Temperatura_Maxima_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Temperatura_Minima_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Total_Precipitacion_mm", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Humedad_Relativa_Media", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Presion_Maxima_hPa", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Presion_Minima_hPa", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Avg_Velocidad_Media_Viento_ms", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Max_Racha_Maxima_Viento_ms", "type": "FLOAT", "mode": "NULLABLE"}
]
EOF
}

