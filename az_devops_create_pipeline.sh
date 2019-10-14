#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

SCRIPT_VERSION=0.1

# Required external tools to be available on PATH.
REQUIRED_TOOLS=("az")

LOG_LEVELS=([0]="emerg" [1]="alert" [2]="crit" [3]="err" [4]="warning" [5]="notice" [6]="info" [7]="debug")
function .log() {
    local LEVEL=${1}
    shift
    if [ ${__VERBOSE} -ge ${LEVEL} ]; then
        if [ ${LEVEL} -ge 3 ]; then
            echo "[${LOG_LEVELS[$LEVEL]}]" "$@" 1>&2
        else
            echo "[${LOG_LEVELS[$LEVEL]}]" "$@"
        fi
    fi
}

__VERBOSE=${__VERBOSE:=6}

function check_tools() {
    local tools=("$@")
    local errors_count=0
    for cmd in "${tools[@]}"
    do
        if ! [[ -x "$(command -v ${cmd})" ]]; then
            .log 3 "${cmd} is required and was not found in PATH."
            errors_count=$((errors_count + 1))
        else
            .log 6 "Found '${cmd}' in path"
        fi
    done

    if [ ${errors_count} -gt 0 ]; then
        exit 1
    fi
}

function usage() {
    echo "" 
    echo "Usage: $0 [-t <pat_token>] -p <pipeline_name> -f <yaml_file> [-h]" 1>&2
    echo "Version: ${SCRIPT_VERSION}"
    echo ""
    echo "Options"
    echo "-t <pat_token>           Personal Access Token that should be used for creating the pipeline."
    echo "                         OR: AZURE_DEVOPS_CLI_PAT environment variable."
    echo "-o <organization>        Azure DevOps org, e.g. 'https://dev.azure.com/contoso/'"
    echo "                         OR: AZURE_DEVOPS_ORGANIZATION environment variable."
    echo "-p <project_name>        Name of the Azure DevOps project, e.g. 'MyProject'."
    echo "                         OR: AZURE_DEVOPS_PROJECT environment variable."
    echo "-x <prefix>              Short 2-10 letters prefix for the project, e.g. 'proj'."
    echo "                         OR: AZURE_DEVOPS_PREFIX environment variable."
    echo "-g <git_repo_name>       Name of the Azure DevOps git repo, e.g. 'myrepo'."
    echo "                         OR: AZURE_DEVOPS_GIT_REPO environment variable."
    echo "-n <pipeline_name>       Name of the pipeline to create, e.g. 'MyPipeline'."
    echo "-f <yaml_file>           YAML definition location relative to the repository root, e.g. './pipeline.yaml'."
    echo "-h                       Help: Print this dialog and exit."
    echo ""
    exit 1
}

# =============================================
# Check Options
t=${AZURE_DEVOPS_CLI_PAT:=""}
o=${AZURE_DEVOPS_ORGANIZATION:=""}
p=${AZURE_DEVOPS_PROJECT:=""}
x=${AZURE_DEVOPS_PREFIX:=""}
g=${AZURE_DEVOPS_GIT_REPO:=""}
n=""
f=""

while getopts ":t:o:p:x:g:n:f:h" z; do
    case "${z}" in
    t)
        t=${OPTARG}
        ;;
    o)
        o=${OPTARG}
        ;;
    p)
        p=${OPTARG}
        ;;
    x)
        x=${OPTARG}
        ;;
    g)
        g=${OPTARG}
        ;;
    n)
        n=${OPTARG}
        ;;
    f)
        f=${OPTARG}
        ;;
    h)
        usage
        ;;
    *)
        usage
        ;;
    esac
done
shift $((OPTIND - 1))

opt_errors_count=0
if [ -z "${t}" ]; then
    .log 3 "PAT Token Missing"
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${o}" ]; then
    .log 3 "Organization missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${p}" ]; then
    .log 3 "Project name missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${x}" ]; then
    .log 3 "Prefix is missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${g}" ]; then
    .log 3 "Git Repo name missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${n}" ]; then
    .log 3 "Pipeline Name missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ -z "${f}" ]; then
    .log 3 "YAML file missing."
    opt_errors_count=$((opt_errors_count + 1))
fi

if [ ${opt_errors_count} -gt 0 ]; then
    usage
fi

.log 6 "[==== Check Required Tools ====]"
.log 6 "Found 'bash' (version: ${BASH_VERSION})"
check_tools "${REQUIRED_TOOLS[@]}"

.log 6 "[==== Login to Azure DevOps ====]"
echo ${t} | az devops login
.log 6 "[==== Creating Pipeline ${n}... (first run is *not* triggered) ====]"
az devops configure --defaults organization="${o}" project="${p}" --use-git-aliases true
az pipelines variable-group create --name "IaC_Shared_Variables" --variables TF_VAR_prefix=${x}
az pipelines variable-group create --name "IaC_Terraform_Backend_Variables" --variables __TF_backend_resource_group_name= __TF_backend_location= __TF_backend_storage_account_name= __TF_backend_storage_container_name=
az pipelines create --name "${n}" --repository "${g}" --branch master --yml-path "${f}" --repository-type tfsgit --skip-first-run
.log 6 "[==== All done. ====]"
