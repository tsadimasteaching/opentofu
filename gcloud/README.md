
# Google Cloud – OpenTofu Configuration

Deploys a Linux VM on Google Cloud Platform with a firewall rule allowing SSH, HTTP, HTTPS, and custom port 8080. After apply, nginx is installed on the VM via a `remote-exec` provisioner.

## Resources created

| Resource | Description |
|---|---|
| `google_compute_instance` | Ubuntu 22.04 LTS VM (`e2-standard-2`) in `europe-west4-b` |
| `google_compute_firewall` | Firewall rule allowing inbound TCP on ports 22, 80, 443, and 8080 |

## Prerequisites

* A Google Cloud account with an active project
* [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed
* [OpenTofu](https://opentofu.org/docs/intro/install/) installed
* An SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`

Authenticate before running any commands:

```bash
gcloud auth login
gcloud auth application-default login
gcloud projects list
gcloud config set project <YOUR_PROJECT_ID>
```

## Configuration

The configuration is currently hard-coded in `main.tf` and `provider.tf`. Edit those files directly to change:

| Setting | Current value | File |
|---|---|---|
| GCP project ID | `hopeful-seat-418610` | `provider.tf` |
| Region | `europe-west4-b` | `provider.tf` |
| Zone | `europe-west4-b` | `main.tf` |
| Machine type | `e2-standard-2` | `main.tf` |
| OS image family | `ubuntu-2204-lts` | `main.tf` |
| SSH username | `rg` | `main.tf` |

## Usage

### Install / upgrade providers

```bash
tofu init --upgrade
```

### Validate (check configuration syntax)

```bash
tofu validate
```

Checks that the configuration is syntactically valid and internally consistent. Does **not** contact GCP and requires no credentials.

### Plan (preview changes)

```bash
tofu plan
```

### Apply (create resources)

```bash
tofu apply
```

The public IP of the VM is printed at the end of apply:

```
Outputs:
  instance_public_ip = "x.x.x.x"
```

Connect to the VM with:

```bash
ssh -i ~/.ssh/id_rsa rg@<instance_public_ip>
```

### Destroy (delete all resources)

```bash
tofu destroy
```

### Clean up local files

Remove the locally generated OpenTofu cache, lock file, and state files:

```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```

| Path | Description |
|---|---|
| `.terraform/` | Downloaded provider plugins and modules |
| `.terraform.lock.hcl` | Provider version lock file |
| `terraform.tfstate` | Current infrastructure state |
| `terraform.tfstate.backup` | Previous state backup |

> **Warning:** always run `tofu destroy` *before* deleting `terraform.tfstate`. Deleting the state file while resources still exist causes OpenTofu to lose track of them.

## Links

* [OpenTofu Google provider docs](https://search.opentofu.org/provider/opentofu/google/latest)
* [Google provider on Terraform Registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
* [Terraform GCP quickstart](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build)