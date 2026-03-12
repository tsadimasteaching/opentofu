
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
* A GCP service account JSON key (see setup below)

### Create a service account key

1. Go to [GCP Console → IAM & Admin → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
2. Create a service account and grant it the **Compute Admin** and **Service Account User** roles
3. Keys tab → **Add Key → JSON** → download the file
4. Copy it to your server:

```bash
mkdir -p ~/.gcp
mv ~/Downloads/your-key.json ~/.gcp/gcloud-key.json
chmod 600 ~/.gcp/gcloud-key.json
```

Set the path in your `.tfvars` as the `credentials` variable.

## Setup

### 1. Create your variables file

```bash
cp example.vars .tfvars
```

Edit `.tfvars` and fill in your values. The file is listed in `.gitignore` so secrets are not committed.

### 2. Variables reference

| Variable | Default | Description |
|---|---|---|
| `project_id` | — | GCP project ID |
| `region` | `europe-west4` | GCP region |
| `zone` | `europe-west4-b` | GCP zone for the instance |
| `machine_type` | `e2-standard-2` | Compute instance machine type |
| `instance_name` | `my-vm` | Name of the compute instance |
| `ssh_user` | — | Linux username for SSH access |
| `credentials` | — | Path to the service account JSON key file |

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
tofu plan --var-file=.tfvars
```

### Apply (create resources)

```bash
tofu apply --var-file=.tfvars
```

The public IP of the VM is printed at the end of apply:

```
Outputs:
  instance_public_ip = "x.x.x.x"
```

Connect to the VM with:

```bash
ssh -i ~/.ssh/id_rsa <ssh_user>@<instance_public_ip>
```

### Destroy (delete all resources)

```bash
tofu destroy --var-file=.tfvars
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