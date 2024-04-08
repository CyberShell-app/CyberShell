function Get-CsAzGovAssignment {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SubId
    )

    # Get the list of security assessments
    $SecurityAssessmentList = AzAPICall -uri "$($azAPICallConf['azAPIEndpointUrls'].ARM)/subscriptions/$SubId/providers/Microsoft.Security/assessments?api-version=2021-06-01" -AzAPICallConfiguration $azAPICallConf -listenOn Value

    # Initialize an array to store governance assignments
    $GovAssignments = [System.Collections.ArrayList]::new()

    # Loop through each security assessment
    foreach ($Assessment in $SecurityAssessmentList) {
        $AssessmentName = $Assessment.name
        $AssessmentDisplayName = $Assessment.properties.displayName
        $ResourceScope = $Assessment.properties.resourceDetails.id

        # Get Assessment Key
        $APIBaseUri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)$ResourceScope/providers/Microsoft.Security/assessments/$AssessmentName/governanceAssignments"
        $APIUri = "$APIBaseUri/?api-version=2021-06-01"
        $AssessmentKey = (AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -listenOn Content).Name

        # Get the Assignment details
        $APIUri = "$APIBaseUri/$AssessmentKey/?api-version=2021-06-01"
        $Assignment = AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -listenOn Content

        # If the assignment is not null, add it to the list
        if ($null -ne $Assignment) {
            $GovAssignments.add($Assignment) | Out-Null
        }

        # Display the progress
        $ProgressPercentage = [math]::Round((($GovAssignments.Count / $SecurityAssessmentList.Count) * 100))
        Write-Progress -Activity "Processing Assessment: $AssessmentDisplayName" -Status "$ProgressPercentage% Completed" -PercentComplete $ProgressPercentage
    }

    # Output the list of governance assignments
    Write-Host "List of Governance Assignments will be updated"
    $GovAssignments.properties | Select-Object assignedResourceId | Format-List

    # Display the total number of governance assignments
    Write-Host "Total Governance Assignments: $($GovAssignments.Count)"

    # Update each assignment
    foreach ($Assignment in $GovAssignments) {
        $AssignmentId = $Assignment.id

        # Body for update request
        $Body = @{
            properties = @{
                remediationDueDate = "06/29/2024 22:00:00"
                isGracePeriod      = $true
            }
        } | ConvertTo-Json

        Write-Host "Updating Assignment Id: $AssignmentId"
        $APIUri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)$AssignmentId/?api-version=2021-06-01"
        AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -method PUT -body $Body
    }
}
