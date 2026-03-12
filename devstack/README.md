# DevStack (OpenStack) – OpenTofu Configuration

Deploys a VM instance on a local DevStack / OpenStack environment and adds an SSH inbound rule to an existing security group.

## Resources created

| Resource | Description |
|---|---|
| `openstack_networking_secgroup_rule_v2` | SSH (port 22) inbound rule on an existing security group |
| `openstack_compute_instance_v2` | VM instance using a specified image and flavor |

## Prerequisites

* A running [DevStack](https://docs.openstack.org/devstack/latest/) environment
* [OpenTofu](https://opentofu.org/docs/intro/install/) installed
* The following IDs sourced from your DevStack environment (see helper commands below):
  * Security group ID (`openstack security group list`)
  * Image ID (`openstack image list`)
  * Flavor ID (`openstack flavor list`)
  * Network name (`openstack network list`)

## Setup

### 1. Source DevStack credentials

```bash
source /opt/stack/devstack/openrc <user> <project>
```

### 2. Gather required IDs

Run these OpenStack CLI commands to find the values needed in `main.tf`:

```bash
openstack image list
openstack flavor list
openstack network list
openstack security group list
openstack keypair list
openstack project list
```

Update `main.tf` with the correct `image_id`, `flavor_id`, `security_group_id`, and network `name` for your DevStack environment.

### 3. Create your variables file

```bash
cp example.vars .tfvars
```

Edit `.tfvars` and fill in your DevStack credentials. The file is listed in `.gitignore` so secrets are not committed.

### 4. Variables reference

| Variable | Description | Example value |
|---|---|---|
| `auth_url` | OpenStack identity endpoint | `http://192.168.1.10/identity` |
| `tenant_name` | Project / tenant name | `demo` |
| `user_name` | OpenStack username | `admin` |
| `password` | OpenStack password | `secret` |
| `region` | OpenStack region | `RegionOne` |

## Usage

### Install / upgrade providers

```bash
tofu init --upgrade
```

### Validate (check configuration syntax)

```bash
tofu validate
```

Checks that the configuration is syntactically valid and internally consistent. Does **not** contact OpenStack and requires no credentials.

### Plan (preview changes)

```bash
tofu plan --var-file=.tfvars
```

### Apply (create resources)

```bash
tofu apply --var-file=.tfvars
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

## Useful helper commands

```bash
# Convert a raw image to qcow2 (e.g. for Alpine Linux)
qemu-img convert -f raw -O qcow2 alpine-standard-3.21.3-x86_64.iso alpine.qcow2

# Create a custom flavor and restrict it to a specific project
openstack flavor create custom.small --id auto --ram 256 --disk 5 --vcpus 1
openstack flavor set custom.small --project <project-id>
```

## Links

* [OpenTofu OpenStack provider docs](https://search.opentofu.org/provider/opentofu/openstack/latest)
* [OpenStack provider on Terraform Registry](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
* [DevStack documentation](https://docs.openstack.org/devstack/latest/)