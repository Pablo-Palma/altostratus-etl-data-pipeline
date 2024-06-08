resource "google_cloud_scheduler_job" "orchestrator_job" {
  name             = "orchestrator-job"
  description      = "Job to trigger the orchestrator workflow"
  schedule         = "0 1 * * *"
  time_zone        = "UTC"
  http_target {
    http_method = "POST"
    uri         = "https://workflowexecutions.googleapis.com/v1/projects/${var.project_id}/locations/us-central1/workflows/orchestratorWorkflow:run"
    oidc_token {
      service_account_email = var.orchestrator_email
    }
  }
}

