function Update-CsAzGovAssignment {
    

    # # Output the list of governance assignments
    # Write-Host "List of Governance Assignments will be updated"
    # $GovAssignments.properties | Select-Object assignedResourceId | Format-List

    # # Display the total number of governance assignments
    # Write-Host "Total Governance Assignments: $($GovAssignments.Count)"

    # # Update each assignment
    # foreach ($Assignment in $GovAssignments) {
    #     $AssignmentId = $Assignment.id

    #     # Body for update request
    #     $Body = @{
    #         properties = @{
    #             remediationDueDate = "06/29/2024 22:00:00"
    #             isGracePeriod      = $true
    #         }
    #     } | ConvertTo-Json

    #     Write-Host "Updating Assignment Id: $AssignmentId"
    #     $APIUri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)$AssignmentId/?api-version=2021-06-01"
    #     AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -method PUT -body $Body
    # }


}