provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_iam_member" "scheduler_admin" {
  project = var.project_id
  role    = "roles/cloudscheduler.admin"
  member  = "serviceAccount:${var.scheduler_service_account_email}"
}

resource "google_project_iam_member" "cloud_functions_invoker" {
  project = var.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${var.scheduler_service_account_email}"
}

resource "google_cloud_scheduler_job" "etl_job" {
  name     = "etl-job"
  schedule = "43 10 * * *"  # Ejecuta a las 12:35 CET/CEST
  time_zone = "Europe/Madrid"  # Zona horaria de España
  project  = var.project_id
  region   = var.region

  http_target {
    http_method = "GET"
    uri         = var.function_url

    oidc_token {
      service_account_email = var.scheduler_service_account_email
    }
  }
}

