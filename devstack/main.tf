terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.50.0"
    }
  }
}

variable "auth_url" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}


provider "openstack" {
    auth_url = var.auth_url
    region = var.region
    tenant_name = var.tenant_name
    user_name = var.user_name
    password = var.password
}




resource "openstack_networking_secgroup_rule_v2" "ssh_rule" {
  security_group_id = "01c7264c-5f31-4cfe-9633-6593e339f74d"
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 22
  port_range_max   = 22
}

resource "openstack_compute_instance_v2" "vm" {
  name            = "devstack-vm"
  image_id        = "45ed8532-b10f-4e0f-a420-0c75ec6ace79"  # Use 'openstack image list' to get this
  flavor_id       = "42" # Use 'openstack flavor list' to get this
  // key_pair        = "argiris_key"       # Use 'openstack keypair list' to get this
  availability_zone = "nova"

  network {
    name = "shared" # Use 'openstack network list' to get this
  }
}
