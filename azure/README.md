# Azure – OpenTofu Configuration

Two independent deployment scenarios controlled by boolean variables in your `.tfvars`. Both share the same resource group.

| Scenario | Variable | What it deploys |
|---|---|---|
| **VM** | `deploy_vm = true` | Ubuntu 24.04 VM + VNet + NSG + auto-shutdown |
| **Webapp** | `deploy_webapp = true` | Spring Boot container (GHCR) + Managed PostgreSQL |

Both can be enabled simultaneously or independently.

## Resources created

### Scenario: VM (`deploy_vm = true`)

| Resource | Description |
|---|---|
| `azurerm_resource_group` | Resource group shared by all resources |
| `azurerm_virtual_network` | Virtual network |
| `azurerm_subnet` | Subnet inside the VNet |
| `azurerm_public_ip` | Static public IP for the VM |
| `azurerm_network_security_group` | NSG allowing inbound SSH (port 22) |
| `azurerm_network_interface` | NIC attached to subnet and public IP |
| `azurerm_network_interface_security_group_association` | Associates the NSG with the NIC |
| `azurerm_linux_virtual_machine` | Ubuntu 24.04 LTS VM |
| `azurerm_dev_test_global_vm_shutdown_schedule` | Auto-shutdown at 22:00 Athens time |
| `local_file` + `null_resource` | Writes SSH config entry to `~/.ssh/config` |

> Requires: `Microsoft.Network`, `Microsoft.Compute` — **not available on Azure for Students subscriptions**.

### Scenario: Spring Boot CaaS + PostgreSQL (`deploy_webapp = true`)

| Resource | Description |
|---|---|
| `azurerm_service_plan` | Linux App Service Plan (configurable SKU) |
| `azurerm_linux_web_app` | Spring Boot container pulled from GHCR |
| `azurerm_postgresql_flexible_server` | Managed PostgreSQL Flexible Server |
| `azurerm_postgresql_flexible_server_database` | Application database on the server |
| `azurerm_postgresql_flexible_server_firewall_rule` | Allows inbound traffic from Azure services |

> Requires: `Microsoft.Web`, `Microsoft.DBforPostgreSQL` — **not available on Azure for Students subscriptions**.

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

#### Scenario toggles

| Variable | Default | Description |
|---|---|---|
| `deploy_vm` | `true` | Enable the Linux VM scenario |
| `deploy_webapp` | `false` | Enable the Spring Boot + PostgreSQL scenario |

#### Common

| Variable | Description | Example value |
|---|---|---|
| `resource_group_name` | Name of the Azure resource group | `devops_rg` |
| `location` | Azure region | `Sweden Central` |
| `sub_id` | Azure subscription ID | `xxxxxxxx-xxxx-...` |
| `email` | Email for shutdown notifications | `you@example.com` |

#### VM scenario

| Variable | Description | Example value |
|---|---|---|
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
| `ssh_public_key` | SSH public key (defined but currently unused — `main.tf` reads `~/.ssh/id_rsa.pub` directly) | `ssh-rsa AAAA...` |

#### Webapp scenario

| Variable | Default | Description |
|---|---|---|
| `app_service_plan_name` | — | App Service Plan name |
| `app_service_plan_sku` | `B1` | SKU — `F1` (free), `B1` (basic), `P1v3` (premium) |
| `webapp_name` | — | Globally unique Web App name |
| `container_image` | — | Image in the form `ghcr.io/<user>/<repo>:<tag>` |
| `container_registry_url` | `https://index.docker.io` | Registry URL — use `https://ghcr.io` for GHCR |
| `container_registry_username` | `""` | Username — empty for public images |
| `container_registry_password` | `""` | Token — empty for public images |
| `container_port` | `8080` | Port Spring Boot listens on |
| `postgres_server_name` | — | PostgreSQL server name (globally unique) |
| `postgres_version` | `16` | PostgreSQL major version |
| `postgres_sku_name` | `B_Standard_B1ms` | Server SKU |
| `postgres_db_name` | — | Application database name |
| `postgres_admin_user` | — | PostgreSQL administrator username |
| `postgres_admin_password` | — | PostgreSQL administrator password |

## Scenarios

### VM only

In `.tfvars`:

```hcl
deploy_vm     = true
deploy_webapp = false
```

```bash
tofu apply --var-file=.tfvars
```

Outputs: `public_ip` — SSH in with:

```bash
ssh <vm_name>
```

### Spring Boot + PostgreSQL only

In `.tfvars`:

```hcl
deploy_vm     = false
deploy_webapp = true
```

```bash
tofu apply --var-file=.tfvars
```

The Spring Boot container receives the following environment variables automatically, which Spring picks up via `spring.datasource.*` binding:

```
SPRING_DATASOURCE_URL      = jdbc:postgresql://<fqdn>:5432/<db>?sslmode=require
SPRING_DATASOURCE_USERNAME = <postgres_admin_user>
SPRING_DATASOURCE_PASSWORD = <postgres_admin_password>
```

Outputs after apply:

```
webapp_url               = "https://<webapp_name>.azurewebsites.net"
postgres_fqdn            = "<server>.postgres.database.azure.com"
postgres_connection_string = "jdbc:postgresql://..."
```

### Both scenarios

```hcl
deploy_vm     = true
deploy_webapp = true
```

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
* [Azure App Service – Linux containers](https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container)
* [Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/overview)
* [GitHub Packages container registry (GHCR)](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
* [OpenTofu `enabled` meta-argument](https://opentofu.org/docs/language/meta-arguments/lifecycle/#enabled)