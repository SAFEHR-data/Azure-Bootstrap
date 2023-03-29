# Azure-Bootstrap

Utility for bootstrapping common Azure resources needed to store Terraform state, containers and configure build agents.

## Getting started

1. Create a new private repository using this template repo, then clone and check it out.

2. Run the initalisation script

```bash
./scripts/init.py
```

3. `az login`

4. Create a Github PAT for registering runners. This PAT must have [admin:org](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization) scopes and will be required when running `make`

5. `make all`
