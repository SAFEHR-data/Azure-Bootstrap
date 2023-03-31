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

3. Log into Azure and optionally set a different subscription from your default:

    ```bash
    az login
    az account set -s <YOUR_SUBSCRIPTION_ID>
    ```

4. Create a fine-grained Github Organization PAT for registering runners, with the **Resource Owner** set to the Organization you want the runners to be shared within. This PAT must have [Organization Administration: Read and write](https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-an-organization) scopes and will be required when running `make`. 

    Copy the value and export it as an environment variable (we don't want this in config as it should be kept secret):

    ```bash
    export GITHUB_RUNNER_PAT=<your_token_here>
    ```

> Note: be conscious of the expiry time that you set. You can generate a new PAT at any time and have shorter expiries for security, but ensure that you re-deploy with the new PAT before the old one expires, otherwise your build agents could stop functioning.

5. Deploy the bootstrap resources:

    ```bash
    make
    ```
