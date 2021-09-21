variable "project_id" {
  description = "The project ID to deploy resource into"
  default = "invertible-tree-322409"
}

variable "region" {
  description = "The GCP region to deploy instances into"
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy instances into"
  default     = "us-central1-c"
}

variable "machine_type" {
  description = "The GCP machine type to deploy"
  default = "e2-medium"
}

variable "image" {
  description = "The base image for the instance"
  default = "debian-cloud/debian-10"
}

variable "disk_name" {
  description = "The name of the additional disk on VM"
  default = "data-disk"
}

variable "workers_count" {
  description = "The number of workers to be created"
  default = "3"
}