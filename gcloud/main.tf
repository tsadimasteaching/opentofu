resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "e2-standard-2"
  zone         = "europe-west4-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-minimal-2210-kinetic-amd64-v20230126"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}