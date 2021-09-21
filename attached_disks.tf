// Additional disks for data
resource "google_compute_disk" "worker" {
  count   = var.workers_count
  name    = "worker${count.index + 1}-attached-disk"
  type    = "pd-ssd"
  size    = 10
}