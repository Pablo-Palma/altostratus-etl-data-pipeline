variable "project_id" {
  description = "The Google Cloud Project ID."
  type        = string
}

variable "scheduler_service_account_email" {
  description = "Email of the service account to use with the Cloud Scheduler job."
  type        = string
}

variable "function_url" {
  description = "The URL of the Cloud Function to trigger by the Cloud Scheduler job."
  type        = string
}

variable "region" {
  description = "The Google Cloud region where the Cloud Scheduler job is deployed."
  type        = string
}

