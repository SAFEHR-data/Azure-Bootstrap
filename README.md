# 🥾 Azure-Bootstrap

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

6. After successfully deploying, the values you'll need to use the bootstrap environment for your CI deployments are printed to the console. Make sure you capture these and use for the next section.


## Using for CI

Using the values outputted from the deployment, you can now configure your other repositories' GitHub actions to use the bootstrap resources.

### Virtual Network Peering

The first thing you need to do in a deployment of resources you wish to be accessible by the bootstrap runners (and anything running in them from your actions, like Terraform) is to [peer](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview) that deployment's virtual network with the bootstrap vnet.

You can do this using the outputted `CI_PEERING_VNET` and `CI_RESOURCE_GROUP` values, which is the bootstrap's vnet name and resource group name. In Terraform, it would look something like this:

```hcl
data "azurerm_virtual_network" "bootstrap" {
    name                = var.ci_vnet_name # Populated from CI_PEERING_VNET
    resource_group_name = var.ci_rg_name # Populated from CI_RESOURCE_GROUP
}

resource "azurerm_virtual_network_peering" "bootstrap_to_flowehr" {
    name                      = "peer-bootstrap-to-flwr"
    resource_group_name       = azurerm_resource_group.flwr.name
    virtual_network_name      = var.ci_vnet_name
    remote_virtual_network_id = azurerm_virtual_network.flwr.name
}

resource "azurerm_virtual_network_peering" "flowehr_to_bootstrap" {
    name                      = "peer-flwr-to-bootstrap"
    resource_group_name       = azurerm_resource_group.flwr.name
    virtual_network_name      = azurerm_virtual_network.flwr.name
    remote_virtual_network_id = data.azurerm_virtual_network.bootstrap.id
}
```

### GitHub Runners

1. Navigate to your GitHub Organization's settings, then Actions, then create a new organization-scoped variable called `CI_GITHUB_RUNNER_LABEL` and paste the corresponding value from the bootstrap output.

> You can do this as a repository-scoped variable instead if you prefer, but will need to make sure you've defined it in every repository in which you wish to populate the runner's label.

2. Configure your relevant GitHub Workflow files to use this (`${{ vars.CI_GITHUB_RUNNER_LABEL }}`) in any relevant job's `runs-on` parameter.

### Storage & Azure Container Registry

A key use-case for having storage and a container registry in a central CI/boostrap environment is for managing [Terraform state](https://learn.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage?tabs=azure-cli) and [Dev containers](https://containers.dev).

For an example of how this is used, see the [UCLH-Foundry/FlowEHR repo](https://github.com/UCLH-Foundry/FlowEHR). The `CI_CONTAINER_REGISTRY` and `CI_STORAGE_ACCOUNT` values are passed in via a GitHub environment and used by the workflows to store dev containers Terraform state for the FlowEHR infrastructure deployments.


## Security considerations

We recommend peering the Bootstrap VNet with a hub network in your organization containing a Network Virtual Appliance (firewall), and configuring your private fork of this repo to implement [User Defined Routes](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview) to direct all traffic to that firewall.

As part of this, ensure that you have whitelisted the appropriate domains that the GitHub runners required to function. See [here](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#communication-requirements) for details.
