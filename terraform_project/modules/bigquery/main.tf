provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_bigquery_dataset" "staging" {
  dataset_id = "staging"
  project    = var.project_id
  location   = "US"
  delete_contents_on_destroy  = true
}

resource "google_bigquery_dataset" "processing" {
  dataset_id = "processing"
  project    = var.project_id
  location   = "US"
  delete_contents_on_destroy  = true
}

resource "google_bigquery_dataset" "reporting" {
  dataset_id = "reporting"
  project    = var.project_id
  location   = "US"
  delete_contents_on_destroy  = true
}

resource "google_bigquery_table" "staging_table" {
  dataset_id = google_bigquery_dataset.staging.dataset_id
  table_id   = "aemet_data"
  project    = var.project_id
  deletion_protection = false

  schema = <<EOF
[
  {"name": "Fecha", "type": "STRING", "mode": "REQUIRED"},
  {"name": "Estacion", "type": "STRING", "mode": "NULLABLE"},
  {"name": "Provincia", "type": "STRING", "mode": "NULLABLE"},
  {"name": "Temperatura_Media_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Temperatura_Maxima_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Temperatura_Minima_C", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Precipitacion_mm", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Humedad_Relativa_Media", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Presion_Maxima_hPa", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Presion_Minima_hPa", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Velocidad_Media_Viento_ms", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "Racha_Maxima_Viento_ms", "type": "FLOAT", "mode": "NULLABLE"}
]
EOF
}

resource "google_bigquery_table" "failed_requests_table" {
  dataset_id = google_bigquery_dataset.staging.dataset_id
  table_id   = "failed_requests"
  project    = var.project_id
  deletion_protection = false

  schema = <<EOF
[
  {"name": "FechaInicio", "type": "STRING", "mode": "REQUIRED"},
  {"name": "FechaFin", "type": "STRING", "mode": "REQUIRED"},
  {"name": "Estacion", "type": "STRING", "mode": "REQUIRED"}
]
EOF
}

output "bigquery_datasets" {
  value = ["staging", "processing", "reporting"]
}

output "staging_table_id" {
  value = "${google_bigquery_dataset.staging.dataset_id}.${google_bigquery_table.staging_table.table_id}"
}

output "failed_requests_table_id" {
  value = "${google_bigquery_dataset.staging.dataset_id}.${google_bigquery_table.failed_requests_table.table_id}"
}
