#!/bin/bash

RELEASE_NAME=${1}
PRODUCT=${2}
PR_NUMBER=${3}
CONTAINER_REGISTRY=${4}

# Extract component from release name (e.g., plum-frontend-pr-1347 -> frontend)
component=$(echo ${RELEASE_NAME} | sed -e "s/^${PRODUCT}-//" -e 's/-pr-.*//')

# Build repository name and task name
# Format matches Jenkins: {repoName}-{prNumber}-build
repository="${PRODUCT}-${component}"
repository_normalized=$(echo ${repository} | tr '/' '-')
task_name="${repository_normalized}-${PR_NUMBER}-build"

echo "Looking for ACR task: $task_name (PR #${PR_NUMBER}) in ${CONTAINER_REGISTRY}"

# Check if task exists (capture stderr to see any permission issues)
task_check_output=$(az acr task show -n ${task_name} -r ${CONTAINER_REGISTRY} --query name -o tsv 2>&1)
task_check_exit=$?

if [ $task_check_exit -eq 0 ] && [ -n "$task_check_output" ]; then
  echo "Task ${task_name} found in ${CONTAINER_REGISTRY}. Deleting..."
  az acr task delete -n ${task_name} -r ${CONTAINER_REGISTRY} --yes
  if [ $? -eq 0 ]; then
    echo "Successfully deleted task ${task_name} from ${CONTAINER_REGISTRY}"
  else
    echo "Failed to delete task ${task_name} from ${CONTAINER_REGISTRY}"
  fi
else
  # Show the actual error if there's a permission or connection issue
  if echo "$task_check_output" | grep -qi "error\|denied\|unauthorized"; then
    echo "Error accessing ${CONTAINER_REGISTRY}: $task_check_output"
  else
    echo "Task ${task_name} not found in ${CONTAINER_REGISTRY}"
  fi
fi
