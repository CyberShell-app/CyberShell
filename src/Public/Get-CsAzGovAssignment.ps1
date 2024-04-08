function Get-CsAzGovAssignment {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$SubId,

        [Parameter(Position = 1, Mandatory = $true)]
        [System.Collections.Hashtable]$azAPICallConf,

        [Parameter(Position = 2, Mandatory = $true)]
        [string]$CsEnvironment
    )

    # Get the list of security assessments
    $SecurityAssessmentList = AzAPICall -uri "$($azAPICallConf['azAPIEndpointUrls'].ARM)/subscriptions/$SubId/providers/Microsoft.Security/assessments?api-version=2021-06-01" -AzAPICallConfiguration $azAPICallConf -listenOn Value

    # Initialize an array to store governance assignments
    $GovAssignments = [System.Collections.ArrayList]::new()

    $counter = 0

    # Loop through each security assessment
    foreach ($Assessment in $SecurityAssessmentList) {

        # Increment the counter
        $counter++

        # Get the assessment details
        $AssessmentName = $Assessment.name
        $AssessmentDisplayName = $Assessment.properties.displayName
        $ResourceScope = $Assessment.properties.resourceDetails.id

        # Display the progress
        $ProgressPercentage = [math]::Round((($counter / $SecurityAssessmentList.Count) * 100))
        Write-Progress -Activity "Processing Assessment: $AssessmentDisplayName" -Status "$ProgressPercentage% Completed" -PercentComplete $ProgressPercentage

        # Get Assessment Key
        $APIBaseUri = "$($azAPICallConf['azAPIEndpointUrls'].ARM)$ResourceScope/providers/Microsoft.Security/assessments/$AssessmentName/governanceAssignments"

        # Get the Assignment details
        $APIUri = "$APIBaseUri/$AssessmentKey/?api-version=2021-06-01"
        $Assignment = AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -listenOn Content -skipOnErrorCode 404

        # If the assignment is not null, add it to the list
        if ($null -ne $Assignment) {
            $APIUri = "$APIBaseUri/?api-version=2021-06-01"
            $AssignmentKey = (AzAPICall -uri $APIUri -AzAPICallConfiguration $azAPICallConf -listenOn Content).Name

            # Create a new GovAssignment object
            $GovAssignmentObj = [GovAssignment]::new()
            $GovAssignmentObj.CsEnvironment = $CsEnvironment
            $GovAssignmentObj.SourceType = 'Az'
            $GovAssignmentObj.AssessmentName = $AssessmentName
            $GovAssignmentObj.AssessmentDisplayName = $AssessmentDisplayName
            $GovAssignmentObj.AssignedResourceId = $Assignment.properties.assignedResourceId
            $GovAssignmentObj.ContainerId = $subId
            $GovAssignmentObj.AssignmentKey = $AssignmentKey
            $GovAssignmentObj.RemediationDueDate = $Assignment.properties.remediationDueDate
            $GovAssignmentObj.IsGracePeriod = $Assignment.properties.isGracePeriod
            $GovAssignmentObj.Owner = $Assignment.properties.owner
            $GovAssignmentObj.OwnerEmailNotification = $Assignment.properties.governanceAssignmentEmailNotification.disableOwnerEmailNotification
            $GovAssignmentObj.ManagerEmailNotification = $Assignment.properties.governanceAssignmentEmailNotification.disableManageremailnotification
            $GovAssignmentObj.NotificationDayOfWeek = $Assignment.properties.governanceAssignmentEmailNotification.notificationDayOfWeek

            # Add the assignment to the list
            $GovAssignments.add($GovAssignmentObj)
        }
    }
    Write-Progress -Completed
    return $GovAssignments
}
