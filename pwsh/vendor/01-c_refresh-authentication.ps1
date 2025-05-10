# authentication over the refresh token
# the valid refresh token persit on disk

$tokenUrl = "https://auth.omas.app/realms/omas/protocol/openid-connect/token"
$clientId = "demo-client"
$refreshToken = Get-Content "$clientId-token.jwt"

if(!$refreshToken) {
    throw "$clientId-token.jwt required"
}  

$body = @{
    grant_type    = "refresh_token"
    client_id     = $clientId
    refresh_token = $refreshToken
}

$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body

if(!$tokenResponse.refresh_token) {
    throw "authentication failed"
}

# maybe the refresh token got renewed
if($refreshToken -ne $tokenResponse.refresh_token) {
    $fileName = "$clientId-token.jwt"
    $tokenResponse.refresh_token | Out-File $fileName -Force
    Write-Host "Refresh token stored in $fileName"
}

Write-Host "New Access Token granted"
$accessToken = $tokenResponse.access_token

#return access token to be used in caller
Write-Output (ConvertTo-SecureString $accessToken -AsPlainText)





