# password registration
# a refresh token is generated over user credentials

$tokenUrl = "https://auth.omas.app/realms/omas/protocol/openid-connect/token"
$clientId = "demo-client"
$scope = "openid omas offline_access"

# ask for credentials
$creds = (Get-Credential -Title "omas user")

# we are requesting directly the tokens
$body = @{
    client_id = $clientId
    scope     = $scope
    grant_type    = "password"
    username 	  = $creds.UserName
    password      = (ConvertFrom-SecureString  $creds.Password -AsPlainText)
}

$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body

# the $tokenResponse.access_token is used to access the api
# the $tokenResponse.refresh_token need to persisted to create a new accessToken at a later time.

if(!$tokenResponse.refresh_token) {
    throw "authentication failed"
}

# persist the refresh token for later use
$fileName = "$clientId-token.jwt"
$tokenResponse.refresh_token | Out-File $fileName -Force
Write-Host "Refresh token stored in $fileName"

Write-Host "New Access Token granted"
$accessToken = $tokenResponse.access_token

#return access token to be used in caller
Write-Output (ConvertTo-SecureString $accessToken -AsPlainText)
