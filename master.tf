// Master instance
resource "google_compute_instance" "master" {
 name         = "master"
 machine_type = var.machine_type
 zone         = var.zone

 boot_disk {
   initialize_params {
     image = var.image
   }
 }

 network_interface {
    subnetwork = google_compute_subnetwork.ansible_network.id
    network_ip = google_compute_address.master.address
 }

  // Install ansible
  metadata_startup_script = "${file("./scripts/install_ansible.sh")}"
}
