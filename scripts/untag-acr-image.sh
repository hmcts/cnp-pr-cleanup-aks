#!/bin/bash

RELEASE_NAME=${1}
PRODUCT=${2}
CONTAINER_REGISTRIES=${3}  # Space-separated list of ACR names

component=$(echo ${RELEASE_NAME} | sed -e "s/^${PRODUCT}-//" -e 's/-pr-.*//')
repository="${PRODUCT}/${component}"
tag=$(echo ${RELEASE_NAME} | sed "s/.*-pr-/pr-/")

echo "Deleting $repository:$tag from multiple ACRs"

for CONTAINER_REGISTRY in ${CONTAINER_REGISTRIES}; do
  echo "Processing ${CONTAINER_REGISTRY}..."
  az acr repository show-tags -n ${CONTAINER_REGISTRY} --repository $repository --query "[?starts_with(@, '$tag')]" -o tsv \
  | xargs -I% az acr repository untag -n ${CONTAINER_REGISTRY} --image "$repository:%" 2>/dev/null || echo "No tags found in ${CONTAINER_REGISTRY}"
done

echo "Deleted $repository:$tag"