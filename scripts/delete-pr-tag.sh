#!/usr/bin/env bash
set -ex

RELEASE_NAME_LABEL=${1}
PR_API_URL=${2}
GIT_TOKEN=${3}

REPO_URL=$(echo "${PR_API_URL%/*/*}")

if [[ -z "$RELEASE_NAME_LABEL" || -z "$PR_API_URL" || -z "$GIT_TOKEN" ]]; then
    echo "Variables are not set - PR potentiall had no labels. Skipping..."
else
    echo "Deleting ${RELEASE_NAME_LABEL} label"

    curl -i -L \
        -X DELETE \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer ${GIT_TOKEN}"\
        -H "X-GitHub-Api-Version: 2022-11-28" \
        ${REPO_URL}/labels/${RELEASE_NAME_LABEL}
fi
