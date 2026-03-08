# Azure – OpenTofu Configuration

Deploys a Linux VM on Azure with a Virtual Network, Subnet, Public IP, Network Security Group (SSH inbound), and an auto-shutdown schedule. The public IP is written to an SSH config file after apply.

## Resources created

| Resource | Description |
|---|---|
| `azurerm_resource_group` | Resource group for all resources |
| `azurerm_virtual_network` | Virtual network |
| `azurerm_subnet` | Subnet inside the VNet |
| `azurerm_public_ip` | Static public IP for the VM |
| `azurerm_network_security_group` | NSG allowing inbound SSH (port 22) |
| `azurerm_network_interface` | NIC attached to subnet and public IP |
| `azurerm_linux_virtual_machine` | Ubuntu 24.04 LTS VM |
| `azurerm_dev_test_global_vm_shutdown_schedule` | Auto-shutdown at 22:00 Athens time |
| `local_file` + `null_resource` | Writes SSH config to `~/.ssh/config` |

## Prerequisites

* An Azure account with an active subscription
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
* [OpenTofu](https://opentofu.org/docs/intro/install/) installed
* An SSH key pair at `~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`

Log in to Azure before running any commands:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

## Setup

### 1. Create your variables file

```bash
cp example.vars .tfvars
```

Edit `.tfvars` and fill in your values. The file is listed in `.gitignore` so secrets are not committed.

### 2. Variables reference

| Variable | Description | Example value |
|---|---|---|
| `resource_group_name` | Name of the Azure resource group | `devops_rg` |
| `location` | Azure region | `Sweden Central` |
| `sub_id` | Azure subscription ID | `xxxxxxxx-xxxx-...` |
| `vm_size` | VM SKU | `Standard_B2s` |
| `vm_name` | Name of the virtual machine | `devopsrg-web-vm` |
| `os_disk_name` | Name of the OS disk | `devopsrg-web-os-disk` |
| `vnet_name` | Virtual network name | `devopsrg-vnet` |
| `vnet_address_space` | VNet CIDR block | `10.0.0.0/16` |
| `subnet_name` | Subnet name | `devopsrg-subnet` |
| `subnet_address_prefix` | Subnet CIDR block | `10.0.1.0/24` |
| `public_ip_name` | Public IP resource name | `devopsrg-web-pip` |
| `nsg_name` | Network Security Group name | `devopsrg-nsg` |
| `nic_name` | Network Interface name | `devopsrg-web-nic` |
| `ssh_public_key` | Contents of your SSH public key | `ssh-rsa AAAA...` |
| `email` | Email for shutdown notifications | `you@example.com` |

## Usage

### Install / upgrade providers

```bash
tofu init --upgrade
```

### Validate (check configuration syntax)

```bash
tofu validate
```

Checks that the configuration is syntactically valid and internally consistent — variable references, resource arguments, and provider schemas are all verified. Does **not** contact Azure and requires no credentials. Run this after editing `.tf` files to catch errors before planning.

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
  public_ip = "x.x.x.x"
```

An SSH entry is also appended to `~/.ssh/config` so you can connect with:

```bash
ssh <vm_name>
```

### Destroy (delete all resources)

```bash
tofu destroy --var-file=.tfvars
```

This removes every resource managed by this configuration from Azure. The local `~/.ssh/config` entry is **not** automatically cleaned up — remove it manually if needed.

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

> **Warning:** deleting `terraform.tfstate` while resources still exist in Azure will cause OpenTofu to lose track of them. Always run `tofu destroy` **before** cleaning local files.

## Links

* [OpenTofu azurerm provider docs](https://search.opentofu.org/provider/opentofu/azurerm/latest)
* [azurerm provider on Terraform Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
* [Azure VM quickstart with Terraform](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform)
* [OpenTofu Azure guide](https://www.iamachs.com/p/opentofu-azure/part-1-deploy-multi-tier-app-guide/)