variable "project" {}

variable "regions" {
  default = ["europe-west1", "europe-west2", "europe-west3", "europe-west4"]
}

variable "count" {
  default = 1
}

variable "node_count" {
  default = 3
}

variable "version" {
  default = "1.9.3-gke.0"
}

variable "machine_type" {
  default = "g1-small"
}
