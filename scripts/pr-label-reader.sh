#!/bin/bash

labels=$1

if [ -n "$labels" ]; then
    echo "JSON Object: $labels"

    # Function to split the label and collect the value
    split_label() {
        label=$1
        IFS=':' read -ra parts <<< "$label"
        echo "${parts[1]}"
    }

    namespace=""
    releaseName=""
    product=""

    # Iterate through PR labels to collect
    for row in $(echo "$labels" | jq -r '.[] | @base64'); do
        _jq() {
            echo "$row" | base64 --decode | jq -r "$1"
        }
        labelName=$(_jq '.name')
        echo "Label name: $labelName"

        if [[ $labelName == ns:* ]]; then
            namespace=$(split_label "$labelName")
        fi
        if [[ $labelName == rel:* ]]; then
            releaseName=$(split_label "$labelName")
        fi
        if [[ $labelName == prd:* ]]; then
            product=$(split_label "$labelName")
        fi
    done

    # Set variables to be used by following tasks
    echo "##vso[task.setvariable variable=release_name]$releaseName"
    echo "##vso[task.setvariable variable=namespace]$namespace"
    echo "##vso[task.setvariable variable=product]$product"

    echo "Release Name: $releaseName"
    echo "Namespace: $namespace"
    echo "Product: $product"
else
    echo "No labels provided. Using default values - Didn't run from webhook"
fi
