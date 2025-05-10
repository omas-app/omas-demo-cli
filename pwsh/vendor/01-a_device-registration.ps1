# device registration
# a device with limit input capabilities will be registered over the oauth device flow

$deviceCodeUrl = "https://auth.omas.app/realms/omas/protocol/openid-connect/auth/device"
$tokenUrl = "https://auth.omas.app/realms/omas/protocol/openid-connect/token"
$clientId = "demo-client"
$scope = "openid omas offline_access"


# we are requesting a short lived device code
$body = @{
    client_id = $clientId
    scope     = $scope
}

$response = Invoke-RestMethod -Uri $deviceCodeUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body

Write-Host "Go to: $($response.verification_uri)"
Write-Host "Enter the code: $($response.user_code)"

# we wait until the device is approved (out of bound) 
$body = @{
    client_id  = $clientId
    grant_type = "urn:ietf:params:oauth:grant-type:device_code"
    device_code = $response.device_code
}

# the poll loop
do {
    Start-Sleep -Seconds 5
    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body -SkipHttpErrorCheck
} while (-not $tokenResponse.access_token)

# the $tokenResponse.access_token is used to access the api
# the $tokenResponse.refresh_token need to persisted to create a new accessToken at a later time.

# we write the refresh token to a file out then we can it use later
$fileName = "$clientId-token.jwt"
$tokenResponse.refresh_token | Out-File $fileName -Force
Write-Host "Refresh token stored in $fileName"

#return access token to be used in caller
Write-Output (ConvertTo-SecureString $tokenResponse.access_token -AsPlainText) 


