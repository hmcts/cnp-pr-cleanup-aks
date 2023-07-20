param (
    # The JSON string containing the labels to process - comes in this case from GitHub PR event
    # and is filtered to only listen for PR closure by webhook in aks-cleanup-nonprod.yaml file.
    [Parameter(Mandatory=$false)]
    [AllowEmptyString()]
    [string]$labels
)

if ($labels -ne "") {
    Write-Output "JSON Object: $labels"
    $labelsJson = ConvertFrom-Json -InputObject $labels

    # Split the label to only collect value
    function Split-Label {
        param([string]$label)
        return $label.Split(":")[1]
    }

    # Iterate through PR labels to collect
    foreach ($label in $labelsJson) {
        $labelName = $label.name
        Write-Output "Label name: $labelName"

        if ($labelName.StartsWith("ns:")) {
            $namespace = Split-Label $labelName
        }
        if ($labelName.StartsWith("rel:")) {
            # Full label set here to be deleted in next job
            Write-Host "##vso[task.setvariable variable=release_name_label;isOutput=true]$labelName"
            $releaseName = Split-Label $labelName
        }
        if ($labelName.StartsWith("prd:")) {
            $product = Split-Label $labelName
        }
    }

    # Write variables to be used by following tasks
    Write-Host "##vso[task.setvariable variable=release_name;isOutput=true]$releaseName"
    Write-Host "##vso[task.setvariable variable=namespace;isOutput=true]$namespace"
    Write-Host "##vso[task.setvariable variable=product;isOutput=true]$product"

    Write-Output "Release Name: $releaseName"
    Write-Output "Namespace: $namespace"
    Write-Output "Product: $product"
} else {
    Write-Output "No labels provided. Using default values - Didn't run from webhook"
}   