# Opinionated Terraform Template for Azure - Sample Deployment

## Understanding the Terraform Deployment Process

The centerpiece of the Terraform deployment process is a simple helper script `run_tf.sh`. For background information and changelog go to: [https://github.com/olohmann/terraform-azure-devops-run_tf](https://github.com/olohmann/terraform-azure-devops-run_tf).

## Setting up an End-to-End Sample Pipeline in Azure DevOps

1. Enable the Multi-Stage Deployment preview. [Enable Multi-Stage Preview](./doc/multi-stage-pipelines-preview.png)
2. Create a PAT token with full access to pipelines. You can delete the PAT token after setting up the pipeline or set its expiry to one day.
3. Install the Azure CLI azure-devops extension: `az extension install --name azure-devops`.
4. Run the `az_devops_create_pipeline.sh` bash script and feed in the required parameters. Details below.

## az_devops_create_pipeline.sh

### Usage

```sh
Usage: ./az_devops_create_pipeline.sh [-t <pat_token>] -p <pipeline_name> -f <yaml_file> [-h]
Version: 0.1

Options
-t <pat_token>           Personal Access Token that should be used for creating the pipeline.
                         OR: AZURE_DEVOPS_CLI_PAT environment variable.
-o <organization>        Azure DevOps org, e.g. 'https://dev.azure.com/contoso/'
                         OR: AZURE_DEVOPS_ORGANIZATION environment variable.
-p <project_name>        Name of the Azure DevOps project, e.g. 'MyProject'.
                         OR: AZURE_DEVOPS_PROJECT environment variable.
-x <prefix>              Short 2-10 letters prefix for the project, e.g. 'proj'.
                         OR: TF_VAR_prefix environment variable.
-g <git_repo_name>       Name of the Azure DevOps git repo, e.g. 'myrepo'.
                         OR: AZURE_DEVOPS_GIT_REPO environment variable.
-n <pipeline_name>       Name of the pipeline to create, e.g. 'MyPipeline'.
-f <yaml_file>           YAML definition location relative to the repository root, e.g. './pipeline.yaml'.
-h                       Help: Print this dialog and exit.
```

### Outcome

The result of the script is a new pipeline:
[Pipeline](./doc/pipeline.png)

... which triggers the creation of the following environments:
[Environments](./doc/environments.png)

## Governance and Security

### PR Trigger

When using YAML pipelines in Azure DevOps, please think about the *security* and *governance* process that you need to establish in your team. What you in general want to avoid is a situation where a tweak to the deployment process would directly be executed without a peer review or sign-off (e.g. using a [PR Trigger](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/triggers?view=azure-devops&tabs=yaml#pr-triggers)).

### Protecting Secrets and Service Connections

In general, you should enable *Authorization* for Service Connections and Variable Groups with sensitive information. By doing so you avoid potential secret exfill from an non-validated build pipeline.

### Multi-Stage Deployment with Manual Approvals

Environments can be assigned a manual approval step. Just run the pipeline once and all environments will be created. Afterwards use the Environments section in Azure DevOps to enable via *Checks*.
[Manual Approvals](./doc/environments-manual-approvals.png)
