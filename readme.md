# HelloID-Task-SA-Target-AzureActiveDirectory-GroupRemoveMembership

## Prerequisites

Before using this snippet, verify you've met with the following requirements:

- [ ] AzureAD app registration
- [ ] The correct app permissions for the app registration
- [ ] User defined variables: `AADTenantID`, `AADAppID` and `AADAppSecret` created in your HelloID portal.
- [ ] Please see our documentation on how to create custom variables: (https://docs.helloid.com/en/variables/custom-variables.html)

## Description

This code snippet executes the following tasks:

1. Define a hash table `$formObject`. The keys of the hash table represent the properties to revoke a membership from a group, while the values represent the values entered in the form.

> To view an example of the form output, please refer to the JSON code pasted below.

```json
{
    "groupId": "groupId",
    "MembersToRevoke": [
        {
            "userId": "userId1",
            "userPrincipalName": "testuser1@mydomain.local"

        },
        {
            "userId": "userId2",
            "userPrincipalName": "testuser2@mydomain.local"
        }
    ]
    
}
```

> :exclamation: It is important to note that the names of your form fields might differ. Ensure that the `$formObject` hashtable is appropriately adjusted to match your form fields.

2. Receive a bearer token by making a POST request to: `https://login.microsoftonline.com/$AADTenantID/oauth2/token`, where `$AADTenantID` is the ID of your Azure Active Directory tenant.

3. revoke the membership from a group using the: `Invoke-RestMethod` cmdlet. The hash table called: `$formObject` is passed to the body of the: `Invoke-RestMethod` cmdlet as a JSON object.