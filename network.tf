// External ip static address for entrypoint
 resource "google_compute_address" "static" {
   name = "entrypoint-ipv4-external-static"
}

// VPC network and subnetwork
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_id}-vpc-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ansible_network" {
  name          = "${var.project_id}-ansible-network"
  ip_cidr_range = "172.16.0.0/28"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

// Cloud NAT for subnetwork
resource "google_compute_router" "router" {
  name    = "${var.project_id}-ansible-network-router"
  region  = google_compute_subnetwork.ansible_network.region
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.project_id}-ansible-network-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

// Static internal ip for master
resource "google_compute_address" "master" {
  name         = "master-internal-ip"
  address_type = "INTERNAL"
  address      = "172.16.0.10"
  subnetwork   = google_compute_subnetwork.ansible_network.id
}

// Firewall rules
resource "google_compute_firewall" "allow_all_internal" {
  name        = "allow-all-internal"
  description = "Allow all internal"
  network     = google_compute_network.vpc_network.name

  source_ranges = ["172.16.0.0/28"]
  allow {
    protocol = "all"
  }
  priority = "1000"
}

resource "google_compute_firewall" "allow_ping_entrypoint" {
  name        = "allow-ping-entrypoint"
  description = "Allow ping entrypoint from anywhere"
  network     = google_compute_network.vpc_network.name

  allow {
    protocol = "icmp"
  }
  priority = "1001"
  target_tags = ["entrypoint"]
}

resource "google_compute_firewall" "allow_ssh_iap" {
  name        = "allow-ssh-iap"
  description = "Allow ssh from IAP range"
  network     = google_compute_network.vpc_network.name

  source_ranges = ["35.235.240.0/20"]
  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  priority = "1002"
}

