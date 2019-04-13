locals {
  attendees = ["${split("\n", chomp(file("${var.attendees_file}")))}"]
  count     = "${length(local.attendees)}"
}

provider "google" {
  project = "${var.project}"
}

data "google_client_config" "default" {}

resource "google_project_iam_member" "default" {
  count = "${local.count}"

  role    = "roles/viewer"
  project = "${var.project}"
  member  = "user:${local.attendees[count.index]}"
}

resource "google_project_iam_binding" "default" {
  depends_on = ["google_project_iam_member.default"]

  project = "${var.project}"
  role    = "roles/container.developer"

  members = "${formatlist("user:%s", local.attendees)}"
}

resource "google_project_services" "default" {
  project = "${var.project}"

  services = [
    "bigquery-json.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "oslogin.googleapis.com",
    "pubsub.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

data "google_compute_zones" "default" {
  count      = "${length(var.regions)}"
  depends_on = ["google_project_services.default"]

  region = "${var.regions[count.index]}"
}

data "google_compute_network" "default" {
  depends_on = ["google_project_services.default"]

  name = "default"
}

resource "google_compute_firewall" "default" {
  depends_on = ["google_project_services.default"]

  name    = "default-allow-node-port"
  network = "${data.google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_container_cluster" "default" {
  count      = "${local.count}"
  depends_on = ["google_project_services.default"]

  lifecycle {
    ignore_changes = [
      "id",
      "zone",
    ]
  }

  name               = "${lower(replace(element(split("@", local.attendees[count.index]), 0), "/[^[:alnum:]]/", "-"))}"
  zone               = "${element(flatten(data.google_compute_zones.default.*.names), count.index)}"
  initial_node_count = "${var.node_count}"
  min_master_version = "${var.version}"
  network            = "${data.google_compute_network.default.self_link}"
  node_version       = "${var.version}"

  node_config {
    machine_type = "${var.machine_type}"
    preemptible  = true

    metadata {
      disable-legacy-endpoints = "true"
    }
  }
}

resource "google_compute_disk" "default" {
  count      = "${local.count}"
  depends_on = ["google_project_services.default"]

  name = "${lower(replace(element(split("@", local.attendees[count.index]), 0), "/[^[:alnum:]]/", "-"))}"
  zone = "${element(google_container_cluster.default.*.zone, count.index)}"
  size = "10"
}
