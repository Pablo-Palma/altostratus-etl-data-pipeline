resource "google_service_account" "orchestrator" {
  account_id   = "orchestrator"
  display_name = "Orchestrator Service Account"
}

resource "google_project_iam_member" "orchestrator" {
  for_each = {
    "roles/owner" : "owner",
    "roles/editor" : "editor",
    "roles/viewer" : "viewer",
    "roles/bigquery.dataEditor" : "bigquery_data_editor",
    "roles/bigquery.jobUser" : "bigquery_job_user",
    "roles/cloudscheduler.jobRunner" : "cloudscheduler_job_runner",
    "roles/workflows.invoker" : "workflows_invoker"
  }
  project = var.project_id
  member  = "serviceAccount:${google_service_account.orchestrator.email}"
  role    = each.key
}

