function Update-CsAzGovAssignment {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$CsEnvironment,

        # [Parameter(Mandatory = $true, ParameterSetName = 'Pipeline', ValueFromPipeline = $true)]
        # [PSCustomObject]$InputObject,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$resourceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$AssessmentName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$assignmentKey,

        [Parameter(Mandatory = $false)]
        [string]$RemediationDueDate,

        [Parameter(Mandatory = $false)]
        [bool]$IsGracePeriod,

        [Parameter(Mandatory = $false)]
        [string]$Owner,

        [Parameter(Mandatory = $false)]
        [bool]$OwnerEmailNotification,

        [Parameter(Mandatory = $false)]
        [bool]$ManagerEmailNotification,

        [Parameter(Mandatory = $false)]
        [Validateset('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')]
        [string]$NotificationDayOfWeek

    )

    # $resourceId = '/subscriptions/9777febd-0778-4939-91ff-2e58200ac9cb/resourcegroups/terraform-core-backend-rg/providers/microsoft.storage/storageaccounts/tfcorebackendsa3056'
    # $assessmentName = '3b3638042-30f5-4056-980d-3a40fa5de8b3'

    # $assignmentKey = '1902388e-73ce-44d2-9ded-7dc49d251773'

    # $uri = "$($azapicallconf.azAPIEndpointUrls.ARM)$resourceId/providers/microsoft.security/assessments/$assessmentName/governanceAssignments/$assignmentKey/?api-version=2021-06-01"

    # $result = AzAPICall -AzAPICallConfiguration $azapiCallConf -uri $uri -method 'GET' -listenOn Content

    # $result | fl

    begin {
        # if the input is not from pipeline, then create a custom object with a single entry
        Write-OutputPadded "Update Azure Governance Assignment" -Type 'information' -isTitle -BlankLineBefore
    }

    process {


        # not possibla to do it this way as by default the bollean values are false
        # if (
        #     $null -eq $RemediationDueDate -and
        #     $null -eq $IsGracePeriod -and
        #     $null -eq $Owner -and
        #     $null -eq $OwnerEmailNotification -and
        #     $null -eq $ManagerEmailNotification
        # ) {
        #     Write-OutputPadded "At least one property to update must be specified !" -IdentLevel 1 -type 'error'
        # }

        Write-OutputPadded "Processing Azure Governance Assignment" -Type 'information' -IdentLevel 1 -BlankLineBefore
        Write-OutputPadded "Resource Id: $resourceId" -Type 'information' -IdentLevel 1
        Write-OutputPadded "Assessment Name: $AssessmentName" -Type 'Verbose' -IdentLevel 1
        Write-OutputPadded "Assignment Key: $assignmentKey" -Type 'Verbose' -IdentLevel 1
        # If ($null -ne $RemediationDueDate) { Write-OutputPadded "Remediation Due Date: $RemediationDueDate" -Type 'Verbose' -IdentLevel 1 }
        # If ($null -ne $IsGracePeriod) { Write-OutputPadded "Is Grace Period: $IsGracePeriod" -Type 'Verbose' -IdentLevel 1 }
        # If ($null -ne $Owner) { Write-OutputPadded "Owner: $Owner" -Type 'Verbose' -IdentLevel 1 }
        # If ($null -ne $OwnerEmailNotification) { Write-OutputPadded "Owner Email Notification: $OwnerEmailNotification" -Type 'Verbose' -Inden }
        # If ($null -ne $ManagerEmailNotification) { Write-OutputPadded "Manager Email Notification: $ManagerEmailNotification" -Type 'Verbose' -I }
        # If ($null -ne $NotificationDayOfWeek) { Write-OutputPadded "Notification Day Of Week: $NotificationDayOfWeek" -Type 'Verbose' -Indent }

    }
}