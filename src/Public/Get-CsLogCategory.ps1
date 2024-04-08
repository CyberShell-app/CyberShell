function Get-CsLogCategory {

    <#
    .SYNOPSIS
    This script retrieves unique Azure resources and their types from the current subscription, and outputs them in a table format.

    .DESCRIPTION
    The script first clears the ListOfLogCategory. It then retrieves all Azure resources in the current subscription using the Get-AzResource cmdlet.
    For each unique resource, it creates a new LogCategoryObj object with the SubscriptionId, LogCategoryObj, and a SourceType of 'Az'.
    These LogCategoryObj objects are added to the ListOfLogCategory.
    Finally, it outputs the ListOfLogCategory in a table format using the Format-Table cmdlet.

    .EXAMPLE
    Retrieve all Azure resources and their types in the current context.
    Get-CsLogCategory

    Retrieve all Azure resources and their types in the current context with logs only.
    Get-CsLogCategory -LogOnly

    .PARAMETER LogOnly
    Si ce paramètre est spécifié, le script retournera uniquement les ressources pour lesquelles il y a des logs de type 'log'.

    .PARAMETER MetricOnly
    Si ce paramètre est spécifié, le script retournera uniquement les ressources pour lesquelles il y a des métriques.

    .NOTES
    Make sure you are logged in to your Azure account and have selected the correct subscription before running this script.
      #>

    param (
        [Parameter(Mandatory = $false)]
        [switch]$LogOnly,

        [Parameter(Mandatory = $false)]
        [switch]$MetricOnly
    )

    if ($LogOnly -and $MetricOnly) {
        throw "The LogOnly and MetricOnly parameters cannot be used at the same time."
    }

    [ListOfLogCategory]::Clear()

    $resources = Get-AzResource | Select-Object SubscriptionId, ResourceType -Unique
    $total = $resources.Count
    $current = 0

    $resources | ForEach-Object {
        $current++
        Write-Progress -Activity "Processing resources" -Status "Resource $current of $total $($_.ResourceTypeName)" -PercentComplete ($current / $total * 100)

        $Resource = [LogCategoryObj]::new(@{
                ContainerId      = $_.SubscriptionId
                ResourceTypeName = $_.ResourceType
                SourceType       = 'Az'
            })
        [ListOfLogCategory]::Add($Resource)
    }

    if ($LogOnly) {
        $ListOfLogCategory = [ListOfLogCategory]::FindAll({ param($r) $r.LogCategory.Length -gt 0 })
    }
    elseif ($MetricOnly) {
        $ListOfLogCategory = [ListOfLogCategory]::FindAll({ param($r) $r.MetricCategory.Length -gt 0 })
    }
    else {
        $ListOfLogCategory = [ListOfLogCategory]::LogCategoryObj
    }

    Write-Output $ListOfLogCategory | Format-Table -AutoSize
}