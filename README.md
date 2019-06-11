# Opinionated Terraform Template for Azure

This is an end-to-end sample of an opinionated Terraform wrapper that eases integration with Azure DevOps pipelines. The basic idea is that you can use the `run_tf.sh` to execute terraform deployments in simple Azure DevOps tasks.

## Structure

```txt
|-01-sample             An example terraform deployment.
|-02-sample-post-deploy An example terraform deployment, that takes a dependency on 01-sample.
.editorconfig           See https://editorconfig.org/
CHANGELOG.md            Tracking the changelog.
LICENSE                 License information on this project.
README.md               This README.
run_tf.sh               A terraform wrapper script that simplifies integration with Azure DevOps.
```

## Usage

Just call the script ```run_tf.sh``` from your console or your Azure Release Pipeline (details below).

```txt
Usage: run_tf.sh [-e <environment_name>] [-v] [-f] [-p] [-h]

Options
-e <environment_name>    Defines an environment name that will be activated
                         as a terraform workspace, e.g. 'dev', 'qa' or 'prod'.
                         Default is terraform's 'default'.
-v                       Validate: perform a terraform validation run.
-f                       Force: Defaults all interaction to yes.
-p                       Print env.
-d                       Download minimal version of terraform client.
-h                       Help: Print this dialog and exit.

You can provide terraform params via passing 'TF_VAR_' prefixed environment vars.
For example:
export TF_VAR_location="northeurope"
Will pass an according variable to all terraform invocations.
```

## Terraform State

Being opinionated, the script will automatically create an Azure Storage Account in predefined way to store the Terraform state securely and automation-friendly in an Azure Storage Account.

The *State Storage Account* will be created in the same subscription as the actual deployment. This is usually a sane default, as separation of environments via subscription will then also safely separate the Terraform state storage by environment. Please remember, that the Terraform state is extremely sensible information. You have to treat it as an administrative resource with the same security policy as the actual application deployment.

You can provide the following environment variables to customize the naming of state storage:

```sh
export __TF_backend_resource_group_name="MySpecialName_RG"
export __TF_backend_location="NorthEurope"
export __TF_backend_storage_account_name="s98si89p"
export __TF_backend_storage_container_name="tf-state"

# comma separated list of IPs and/or CIDRs 
export __TF_backend_network_access_rules="23.92.28.29,126.20.2.0/24"
```

> **Please Note:** If no customization is applied, sane defaults will be chosen.

## Integration into Azure DevOps

### Build Pipeline for Validation (Optional)

Integration into the build pipeline for validation and artefact passing is simple. You just need to hook up the `run_tf.sh` script with the parameters `-v` for validation only and `-f` for non-interactive.

Here is a yaml dump of such a pipeline:

```yaml
steps:
- task: AzureCLI@1
  displayName: Validate
  inputs:
    azureSubscription: '<Azure Subscription Reference>'
    scriptPath: 'run_tf.sh'
    arguments: '-v -f'
    addSpnToEnvironment: true
```

> **Please note**: It is important to use the Azure CLI task *and* selecting to pass the SPN details in the actual task (`addSpnToEnvironment: true`). This allows the `run_tf.sh` script to automatically detect that it is being used in combination with a service principal in an Azure CLI pipeline task.

In addition, you can add as many `TF_VAR_`-prefixed variables as required to pass parameters to the terraform deployment. To override the location value, for example, you can pass a `TF_VAR_location` variable:

```yaml
variables:
  TF_VAR_location: 'North Europe'
```

### Release Pipeline

As long as Azure DevOps is not supporting direct YAML integration, you have to setup the environment configuration manually or use the other import options in Azure DevOps.
However, using `run_tf.sh`, the setup is straight and simple. Just use the Azure CLI task as in the optional build pipeline and make sure to set the `addSpnToEnvironment` to true. Only the arguments are different: `-e` for passing the environment name (like dev, qa, or prod) and `-f` for non-interactive.

```yaml
steps:
- task: AzureCLI@1
  displayName: 'Terraform Apply'
  inputs:
    azureSubscription: '<Azure Subscription Reference>'
    scriptPath: '$(System.DefaultWorkingDirectory)/_terraform-reference/run_tf.sh'
    arguments: '-e $(Release.EnvironmentName) -f'
    addSpnToEnvironment: true
    workingDirectory: '$(System.DefaultWorkingDirectory)/_terraform-reference'
```
