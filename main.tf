# Define your provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
  #impersonate_service_account = var.impersonate_service_account
}

resource "google_compute_network" "vpc_network" {
  project = var.project_id
  name    = "db2-vpc-network"
  #routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "db2-vpc-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc_network.id
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "db-server"
  machine_type = "e2-small"
  zone         = var.zone

  tags = ["db2"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      type  = "pd-standard"
      size  = 50
    }
  }

  # Startup script for setting up DB2
  metadata_startup_script = file("startupscript.sh")

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address

    }
  }
}
resource "google_compute_firewall" "default" {
  name        = "test-firewall"
  network     = google_compute_network.vpc_network.name
  description = "DB2 traffic"

  allow { // Allow SSH traffic
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
