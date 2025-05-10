# query api info endpoint
# the endpoint returns the authenticated user infos

$endpoint = "https://api.omas.app/info"


#we are refreshing the access token on each request
#the access token should be normaly used till expiration
$global:accessToken = (.\01-c_refresh-authentication.ps1)

$response = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint

Write-Host "response: $response"


