# Azure-Bootstrap

Utility for bootstrapping common Azure resources needed to store Terraform state, containers and configure build agents.

## Pre-requisites

This repo uses Terraform, Terragrunt and the Azure CLI. Ensure you're either running this repo from its [Devcontainer in VS Code](https://code.visualstudio.com/docs/devcontainers/containers) by selecting `Re-open in Container`, or that you have [Terraform](https://developer.hashicorp.com/terraform/downloads), [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) and the [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed on your local machine. 

## Getting started

1. Create a new private repository using this template repo, then clone and check it out.

2. If you wish to check in your state and config (we recommend you do so it's not just saved on your local machine), remove this from the `.gitignore` file:

    ```
    # Exclude the top level config file
    config.tfvars
    # Exclude the terraform state in the public template repo
    *terraform.tfstate*
    terraform.tfstate
    ```

3. `az login`

4. Create a Github PAT for registering runners. This PAT must have [admin:org](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization) scopes and will be required when running `make`

5. `make all`
