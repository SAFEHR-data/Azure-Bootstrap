# Azure-Bootstrap

Utility for bootstrapping common Azure resources needed to store Terraform state, containers and configure build agents.

## Getting started

1. Create a new private repository using this template repo, then clone and check it out.

2. Copy the sample `config.sample.tfvars` to `config.tfvars` and edit to include a unique suffix (i.e. your org name) and choose an Azure region to deploy to

```
cp config.sample.tfvars config.tfvars
# edit config.tfvars
sed '/config.tfvars/d' .gitignore
```

3. `az login`

4. `make all`
