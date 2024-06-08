variable "project_id" {
  description = "The ID of the project"
}

variable "region" {
  description = "The region where resources will be created"
  default     = "us-central1"
}

variable "credentials_path" {
  description = "Path to the service account credentials file"
}

variable "connector_image" {
  description = "The Docker image for the connector"
}

variable "aemet_api_key" {
  description = "API key for accessing AEMET data"
}

