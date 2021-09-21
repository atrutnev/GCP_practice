// Compute Engine instance
resource "google_compute_instance" "entrypoint" {
 name         = "entrypoint"
 machine_type = var.machine_type
 zone         = var.zone
 allow_stopping_for_update = true
 tags = ["entrypoint"]

 boot_disk {
   initialize_params {
     image = var.image
   }
 }

 network_interface {
    subnetwork = google_compute_subnetwork.ansible_network.id
    access_config {
        nat_ip = google_compute_address.static.address
    }
 }
}