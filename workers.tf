data "template_file" "additional_disk" {
  template = "${file("./scripts/format_and_mount_attached_disk.sh")}"
  vars = {
    disk_name = var.disk_name
  }
}

resource "google_compute_instance_template" "workers_template" {
  name         = "workers-template"
  machine_type = var.machine_type

  disk {
    source_image      = var.image
    auto_delete       = true
    boot              = true
  }

 network_interface {
      subnetwork = google_compute_subnetwork.ansible_network.id
  }

  // Format and mount the attached disk
  metadata_startup_script = "${data.template_file.additional_disk.rendered}"
}

resource "google_compute_instance_from_template" "worker" {
  count                    = var.workers_count
  name                     = "worker${count.index + 1}"
  source_instance_template = google_compute_instance_template.workers_template.id
  zone                     = var.zone
  
  attached_disk {
    // source      = "${element(google_compute_disk.worker.*.name, count.index + 1)}"
    source      = sort(google_compute_disk.worker.*.name)[count.index]
    device_name = var.disk_name
  }

  network_interface {
      subnetwork = google_compute_subnetwork.ansible_network.id
  }
}


