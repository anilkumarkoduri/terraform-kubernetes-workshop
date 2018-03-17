provider "google" {
  project = "${var.project}"
}

data "google_client_config" "default" {}

data "google_compute_zones" "default" {
  count = "${length(var.regions)}"

  region = "${var.regions[count.index]}"
}

resource "google_compute_firewall" "default" {
  name    = "default-allow-node-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_container_cluster" "default" {
  count = "${var.count}"

  name               = "cluster-${count.index + 1}"
  zone               = "${element(flatten(data.google_compute_zones.default.*.names), count.index)}"
  initial_node_count = "${var.node_count}"
  min_master_version = "${var.version}"
  node_version       = "${var.version}"

  node_config {
    machine_type = "${var.machine_type}"
    preemptible  = true
  }
}

resource "google_compute_disk" "default" {
  count = "${var.count}"

  name = "disk-${count.index + 1}"
  zone = "${element(google_container_cluster.default.*.zone, count.index)}"
  size = "10"
}
