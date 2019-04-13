variable "project" {}

variable "regions" {
  default = ["europe-west1", "europe-west2", "europe-west3", "europe-west4", "europe-west6"]
}

variable "node_count" {
  default = 2
}

variable "version" {
  default = "1.12.6-gke.10"
}

variable "machine_type" {
  default = "g1-small"
}

variable "attendees_file" {
  default = "attendees.csv"
}
