provider "google" {
  project     = var.project_id
  region      = var.region
  credentials = file(var.credentials_path)
}

module "connector" {
  source = "./modules/connector"
  project_id = var.project_id
  region = var.region
#  aemet_api_key = var.aemet_api_key
}

module "bigquery" {
  source = "./modules/bigquery"
  project_id = var.project_id
}

module "transformation" {
  source = "./modules/transformation"
  project_id = var.project_id
}

