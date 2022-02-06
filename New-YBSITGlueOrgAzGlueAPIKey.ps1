[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Org_ID
)

$org = Get-ITGlueOrganizations -id $Org_ID

if ($org.data.attributes.'organization-type-name' -ne "Customer") {
    Write-Error "Will not act on company type `"$($org.data.attributes.'organization-type-name')`""
    exit 1
}

$NewKey = [guid]::NewGuid().ToString()

$PasswordObjectName = "AzGlueAPIKey"

$PasswordObject = @{
    type = 'passwords'
    attributes = @{
            name = $PasswordObjectName
            password = $NewKey
            notes = "API Key used for this org to access ITGlue resources via the YBS AZ Proxy."
    }
}

#Now we'll check if it already exists, if not. We'll create a new one.
$ExistingPasswordAsset = (Get-ITGluePasswords -filter_organization_id $org_ID -filter_name $PasswordObjectName).data
#If the Asset does not exist, we edit the body to be in the form of a new asset, if not, we just upload.
if(!$ExistingPasswordAsset){
    Write-Host "Creating new password for $($org.data.attributes.name)" -ForegroundColor yellow
    $ITGNewPassword = New-ITGluePasswords -organization_id $org_ID -data $PasswordObject
} else {
    Write-Host "Updating password for $($org.data.attributes.name)" -ForegroundColor yellow
    $ITGNewPassword = Set-ITGluePasswords -id $ExistingPasswordAsset.id -data $PasswordObject
}
$NewKey