# Azure-Bootstrap

Utility for bootstrapping common Azure resources needed to store Terraform state, containers and configure build agents.

## Getting started

1. Create a new private repository using this template repo, then clone and check it out.

2. Copy the sample `config.sample.tfvars` to `config.tfvars` and edit to include a unique suffix (i.e. your org name) and choose an Azure region to deploy to

```bash
cp config.sample.tfvars config.tfvars
# manually edit config.tfvars
sed '/config.tfvars/d' .gitignore
sed '/terraform.tfstate/d' .gitignore
```

3. `az login`

4. Create a Github PAT for registering runners. This PAT must have [admin:org](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization) scopes and will be required when running `make`

5. `make all`
