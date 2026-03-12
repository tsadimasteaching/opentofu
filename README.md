# OpenTofu – Sample Repository

Sample OpenTofu configurations for multiple cloud providers.

## Providers

| Directory | Provider |
|---|---|
| `azure/` | Microsoft Azure |
| `gcloud/` | Google Cloud (GCP) |
| `devstack/` | OpenStack / DevStack |

---

## 1. Install OpenTofu (standalone method)

The standalone installer downloads a self-contained binary — no package manager required.

```bash
# Download and run the install script
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh \
  | sh -s -- --install-method standalone
```

The binary is placed in `/usr/local/bin/tofu` by default. Verify the installation:

```bash
tofu --version
```

> Full documentation: https://opentofu.org/docs/intro/install/standalone/

---

## 2. Install Azure CLI

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Verify:

```bash
az --version
```

Log in and select your subscription:

```bash
az login
az account set --subscription "<your-subscription-id>"
```

> Full documentation: https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux

---

## 3. Install Google Cloud SDK (gcloud)

```bash
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
  https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install the SDK
sudo apt-get update && sudo apt-get install -y google-cloud-cli
```

Verify:

```bash
gcloud --version
```

Authenticate and set your project:

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <YOUR_PROJECT_ID>
```

> Full documentation: https://cloud.google.com/sdk/docs/install

---

## 4. Running the examples

Each provider directory contains an `example.vars` file. Copy it to `.tfvars`, fill in your values, then use the standard OpenTofu workflow:

### Azure

```bash
cd azure/
cp example.vars .tfvars
# Edit .tfvars with your subscription ID, VM name, SSH key, etc.

tofu init
tofu validate
tofu plan  --var-file=.tfvars
tofu apply --var-file=.tfvars
# When finished:
tofu destroy --var-file=.tfvars
```

See [azure/README.md](azure/README.md) for the full variables reference and resource list.

### Google Cloud

```bash
cd gcloud/
tofu init
tofu validate
tofu plan
tofu apply
# When finished:
tofu destroy
```

See [gcloud/README.md](gcloud/README.md) for details.

### DevStack (OpenStack)

```bash
cd devstack/
cp example.vars .tfvars
# Edit .tfvars with your DevStack credentials and endpoint

tofu init
tofu validate
tofu plan  --var-file=.tfvars
tofu apply --var-file=.tfvars
# When finished:
tofu destroy --var-file=.tfvars
```

See [devstack/README.md](devstack/README.md) for details.

---

## General OpenTofu workflow

| Command | Purpose |
|---|---|
| `tofu init` | Download provider plugins |
| `tofu init --upgrade` | Upgrade providers to latest allowed version |
| `tofu validate` | Check configuration syntax (no credentials needed) |
| `tofu plan` | Preview changes |
| `tofu apply` | Create / update resources |
| `tofu destroy` | Delete all managed resources |

### Clean up local cache

```bash
rm -rf .terraform .terraform.lock.hcl terraform.tfstate terraform.tfstate.backup
```

> **Warning:** always run `tofu destroy` *before* deleting `terraform.tfstate`. Deleting the state file while resources still exist causes OpenTofu to lose track of them.
