provider "google" {
  project = var.project_id
  region  = var.region
}

module "bigquery" {
  source     = "../../bigquery"
  project_id = var.project_id
  region     = var.region
}

# Leer el secreto desde Google Secret Manager
data "google_secret_manager_secret_version" "api_key" {
  secret = "aemet_api_key"
  version = "latest"
}

# Subir el código de la función a Cloud Storage
resource "google_storage_bucket" "function_code" {
  name     = "${var.project_id}-function-code"
  location = var.region
}

resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.function_code.name
  source = "${path.module}/app/function-source.zip"
}

# Crear la Cloud Function
resource "google_cloudfunctions_function" "aemet_connector" {
  name        = "aemet-connector"
  description = "Fetches data from AEMET and loads it into BigQuery"
  runtime     = "python39"
  region      = var.region

  source_archive_bucket = google_storage_bucket.function_code.name
  source_archive_object = google_storage_bucket_object.function_zip.name
  entry_point           = "main"

  environment_variables = {
    API_KEY           = data.google_secret_manager_secret_version.api_key.secret_data
    BIGQUERY_TABLE_ID = "${var.project_id}.${module.bigquery.staging_table_id}"
    FAILED_REQUESTS_TABLE_ID = "${module.bigquery.failed_requests_table_id}"
  }

  trigger_http = true

  available_memory_mb   = 256
  timeout               = 60
}

# Permitir invocaciones no autenticadas de la función
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.aemet_connector.project
  region         = google_cloudfunctions_function.aemet_connector.region
  cloud_function = google_cloudfunctions_function.aemet_connector.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}

# Otorgar permisos a la función para acceder al secreto
resource "google_project_iam_member" "function_secret_access" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_cloudfunctions_function.aemet_connector.service_account_email}"
}

output "cloud_function_url" {
  value = google_cloudfunctions_function.aemet_connector.https_trigger_url
}

