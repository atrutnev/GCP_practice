// Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  credentials = file("~/.creds/SA_credentials.json")
  region  = var.region
  zone    = var.zone
}
