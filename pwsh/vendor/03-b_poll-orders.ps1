# poll modified orders

./00_configuration.ps1

# resource name see https://google.aip.dev/122
$parent = "vendors/$vendor"
$endpoint = "https://api.omas.app/v1/$parent/orders:poll"


#we are refreshing the access token on each request
#the access token should be normaly used till expiration
$global:accessToken = (.\01-c_refresh-authentication.ps1)

# the poll loop
$pageToken = (Get-Content "poll-orders.token" -ErrorAction SilentlyContinue) ?? ""

Write-Host "polling endpoint: $endpoint"

do {  
    # the access token expiration date need to be checked here
    # and if required a new access token need to be requested

    Write-Host "polling for modified orders"
    $response = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri "$($endpoint)?pageToken=$($pageToken)"

    if(!$response.fulfillments) {
        Write-Host "$($response.fulfillments.Length) orders polled"       

        # process orders
        # pending orders need to be acknowledge (asap) and in a short time period after accepted or declined
        # all new state changes will get polled again  
        
        #emit custom event for script reuse
        $response.fulfillments | ForEach-Object {
            New-Event -SourceIdentifier "OrderReceived" -MessageData $_ | Out-Null
        }

    } else {
        Write-Host "no modified orders"
    }

    # persist pageToken
    if($pageToken -ne $response.nextPageToken) {
        $response.nextPageToken | Out-File "poll-orders.token" -Force
    }

    # advance page token
    $pageToken = $response.nextPageToken

    # wait till next poll, the period should be short
    # request is a long poll
    Start-Sleep -Seconds 1
} while ($true)
