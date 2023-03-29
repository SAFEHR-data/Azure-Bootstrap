# Azure-Bootstrap

Utility for bootstrapping common Azure resources needed to store Terraform state, containers and configure build agents.

## Getting started

1. Create a new repository using this template repo, then clone and check it out.

2. Modify the `config.tfvars` to use a unique suffix (i.e. your org name) and choose an Azure region to deploy to

3. `az login`

4. `make all`
