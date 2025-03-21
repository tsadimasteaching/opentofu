# Prerequisites

* have an account in azure portal with a subscription
* [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* login to your azure account from az cli ``az login`` and select the appropriate subscription [Azure Provider]* read (https://search.opentofu.org/provider/opentofu/azurerm/latest) documementation

## create a var file e.g. .tvars (this is in .gitignore)

```bash
cp example.vars  .tfvars
```

### install dependencies

```bash
tofu init --upgrade
```

### Plan

```bash
tofu plan --var-file=.tfvars
```

### Apply

```bash
tofu apply --var-file=.tfvars
```

* Public ip will be printed using outputs.tf

https://www.iamachs.com/p/opentofu-azure/part-1-deploy-multi-tier-app-guide/
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform
