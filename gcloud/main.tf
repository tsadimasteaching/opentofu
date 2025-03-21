resource "google_compute_instance" "default" {
  name         = "my-vm"
  machine_type = "e2-standard-2"
  zone         = "europe-west4-b"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    "ssh-keys" = "rg:${file("~/.ssh/id_rsa.pub")}"
  }

  tags = ["allow-ssh-http-https-8080"]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "rg"
      private_key = file("~/.ssh/id_rsa")
      host        = self.network_interface[0].access_config[0].nat_ip
    }
  }
}

# Create a firewall rule to allow SSH (port 22), HTTP (port 80), HTTPS (port 443), and custom port 8080
resource "google_compute_firewall" "allow_ssh_http_https_custom_ports" {
  name    = "allow-ssh-http-https-8080"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["allow-ssh-http-https-8080"]
}