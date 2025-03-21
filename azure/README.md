

## create a var file e.g. .tvars (this is in .gitignore)

```bash
cp example.tfvars  .tfvars 
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



https://www.iamachs.com/p/opentofu-azure/part-1-deploy-multi-tier-app-guide/
https://learn.microsoft.com/en-us/azure/virtual-machines/windows/quick-create-terraform
