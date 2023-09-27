# HelloID-Task-SA-Target-AzureActiveDirectory-GroupRevokeMembership
##################################################################
# Form mapping
$formObject = @{
    GroupIdentity   = $form.GroupIdentity
    membersToRevoke = $form.membersToRevoke
}
try {
    Write-Information "Executing AzureActiveDirectory action: [GroupRevokeMembership] for: [$($formObject.GroupIdentity)]"
    Write-Information "Retrieving Microsoft Graph AccessToken for tenant: [$AADTenantID]"
    $splatTokenParams = @{
        Uri         = "https://login.microsoftonline.com/$($AADTenantID)/oauth2/token"
        ContentType = 'application/x-www-form-urlencoded'
        Method      = 'POST'
        Body        = @{
            grant_type    = 'client_credentials'
            client_id     = $AADAppID
            client_secret = $AADAppSecret
            resource      = 'https://graph.microsoft.com'
        }
    }
    $accessToken = (Invoke-RestMethod @splatTokenParams).access_token

    $headers = [System.Collections.Generic.Dictionary[string, string]]::new()
    $headers.Add('Authorization', "Bearer $($accessToken)")
    $headers.Add('Content-Type', 'application/json')

    foreach ($member in $formObject.MembersToRevoke) {
        try {
            $splatRevokeMembershipFromGroup = @{
                Uri         = "https://graph.microsoft.com/v1.0/groups/$($formObject.GroupIdentity)/members/$($member.UserId)/`$ref"
                ContentType = 'application/json'
                Method      = 'DELETE'
                Headers     = $headers
                Body        = @{ '@odata.id' = "https://graph.microsoft.com/v1.0/users/$($member.userPrincipalName)" } | ConvertTo-Json -Depth 10
            }
            $null = Invoke-RestMethod @splatRevokeMembershipFromGroup

            $auditLog = @{
                Action            = 'UpdateResource'
                System            = 'AzureActiveDirectory'
                TargetIdentifier  = $formObject.GroupIdentity
                TargetDisplayName = $formObject.GroupIdentity
                Message           = "AzureActiveDirectory action: [GroupRevokeMembership] from group [$($formObject.GroupIdentity)] for: [$($member.userPrincipalName)] executed successfully"
                IsError           = $false
            }

            Write-Information -Tags 'Audit' -MessageData $auditLog
            Write-Information "AzureActiveDirectory action: [GroupRevokeMembership] from group [$($formObject.GroupIdentity)] for: [$($member.userPrincipalName)] executed successfully"
        } catch {
            $ex = $_
            if (-not[string]::IsNullOrEmpty($ex.ErrorDetails)) {
                $errorExceptionDetails = ($_.ErrorDetails | ConvertFrom-Json).error.Message
            } else {
                $errorExceptionDetails = $ex.Exception.Message
            }

            if (($ex.Exception.Response) -and ($Ex.Exception.Response.StatusCode -eq 404)) {
                # 404 indicates already removed
                $auditLog = @{
                    Action            = 'UpdateResource'
                    System            = 'AzureActiveDirectory'
                    TargetIdentifier  = $formObject.GroupIdentity
                    TargetDisplayName = $formObject.GroupIdentity
                    Message           = "AzureActiveDirectory action: [GroupRevokeMembership from group [$($formObject.GroupIdentity))] ] for: [$($member.userPrincipalName)] executed successfully. Note that the account was not a member"
                    IsError           = $false
                }
                Write-Information -Tags 'Audit' -MessageData $auditLog
                Write-Information "AzureActiveDirectory action: [GroupRevokeMembership from group [$($formObject.GroupIdentity))] ] for: [$($member.userPrincipalName)] executed successfully.  Note that the account was not a member"
            } else {
                $auditLog = @{
                    Action            = 'UpdateResource'
                    System            = 'AzureActiveDirectory'
                    TargetIdentifier  = $formObject.GroupIdentity
                    TargetDisplayName = $formObject.GroupIdentity
                    Message           = "Could not execute AzureActiveDirectory action: [GroupRevokeMembership] from group [$($formObject.GroupIdentity)] for: [$($member.userPrincipalName)], error: $($errorExceptionDetails)"
                    IsError           = $true
                }
                Write-Information -Tags 'Audit' -MessageData $auditLog
                Write-Error "Could not execute AzureActiveDirectory action: [GroupRevokeMembership] from group [$($formObject.GroupIdentity)] for: [$($member.userPrincipalName)], error: $($errorExceptionDetails)"
            }
        }
    }
} catch {
    $ex = $_
    if (-not[string]::IsNullOrEmpty($ex.ErrorDetails)) {
        $errorExceptionDetails = ($_.ErrorDetails | ConvertFrom-Json).error.Message
    } else {
        $errorExceptionDetails = $ex.Exception.Message
    }

    $auditLog = @{
        Action            = 'UpdateResource'
        System            = 'AzureActiveDirectory'
        TargetIdentifier  = $formObject.GroupIdentity
        TargetDisplayName = $formObject.GroupIdentity
        Message           = "Could not execute AzureActiveDirectory action: [GroupRevokeMembership] for group: [$($formObject.GroupIdentity)], error: $($errorExceptionDetails)"
        IsError           = $true
    }

    Write-Information -Tags "Audit" -MessageData $auditLog
    Write-Error "Could not execute AzureActiveDirectory action: [GroupRevokeMembership] from group [$($formObject.GroupIdentity)] for: [$($owner.userPrincipalName)], error: $($errorExceptionDetails)"
}
##################################################################