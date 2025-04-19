variable "project_id" {
  description = "A GCP project ID."
  type        = string
}

variable "region" {
  description = "A default GCP region"
  type        = string
}

variable "zone" {
  description = "A default GCP zone"
  type        = string
}

variable "name" {
  description = "Name of kubernetes cluster."
  type        = string
}

variable "node_count" {
  description = "A number of kubernetes nodes."
  type        = number
}

variable "machine_type" {
  description = "A machine type for kubernetes nodes."
  type        = string
}
