# Opinionated Terraform Template for Azure

This is an end-to-end sample of an opinionated Terraform wrapper that eases integration with Azure DevOps pipelines.

## Structure

```txt
|-00-tf-backend     Configures a backend storage account for the following deployment modules.
|-01-sample         An example terraform deployment, that uses the backend config.
.editorconfig       See https://editorconfig.org/
check_tools.sh      A helper script used to verify local tooling requirements (e.g. jq, az, python)
LICENSE             License information on this project.
README.md           This README.
run_tf.sh           A terraform wrapper script that simplifies integration with Azure DevOps.
```

## Usage

Just call the script ```run_tf.sh``` from your console or your Azure Release Pipeline (details below).

```txt
Usage: run_tf.sh [-e <environment_name>] [-i <tf_var_file>] [-v] [-f] [-h]

Options
-e <environment_name>    Defines an environment name that will be activated
                         as a terraform workspace, e.g. 'dev', 'qa' or 'prod'.
                         Default is terraform's 'default'.
-i <tf_var_file>         Defines an OPTIONAL terraform variables file that
                         contains terraform key value pairs..
-v                       Validate: perform a terraform validation run.
-f                       Force: Defaults all interaction to yes.
-h                       Help: Print this dialog and exit.

You can provide terraform params via passing '__TF_' prefixed environment vars.
For example:
export __TF_location=northeurope
Will pass a -var "location=northeurope" to all terraform invocations.
```

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

In addition, you can add as many `__TF_`-prefixed variables as required to pass parameters to the terraform deployment. To override the location value, for example, you can pass a `__TF_location` variable:

```yaml
variables:
  __TF_location: 'North Europe'
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
