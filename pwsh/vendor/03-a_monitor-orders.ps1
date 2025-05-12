# poll modified orders

./00_configuration.ps1

# resource name see https://google.aip.dev/122
$parent = "vendors/$vendor"
$endpoint = "https://api.omas.app/v1/$parent/orders:monitor"


#we are refreshing the access token on each request
#the access token should be normaly used till expiration
$global:accessToken = (.\01-c_refresh-authentication.ps1)

# the poll loop
$nextSeq = (Get-Content "monitor-orders.token" -ErrorAction SilentlyContinue) ?? "0"

Write-Host "monitor for orders in streaming mode"

# the response content type is json-lines
# we are using the standard HttpClient to use a stream to read the lines
$client = New-Object System.Net.Http.HttpClient
$client.DefaultRequestHeaders.Authorization = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", (ConvertFrom-SecureString $accessToken -AsPlainText))

$response = $client.GetAsync("$($endpoint)?startSeq=$($nextSeq)", [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

if($response.StatusCode -ne 200) {
    throw "invalid response: $($response.ReasonPhrase)"
}

Write-Host "reading streaming result"

$stream = $response.Content.ReadAsStreamAsync().Result
$reader = New-Object System.IO.StreamReader($stream)

while (-not $reader.EndOfStream) {   
    $msg = $reader.ReadLine() | ConvertFrom-Json

    if(!$msg.seq) {
        Write-Host "pulse received: $($msg.ts)"        
        continue
    }

    Write-Host "order received: $($msg.fulfillment.name)"

    #emit custom event for script reuse
    New-Event -SourceIdentifier "OrderReceived" -MessageData $msg.fulfillment | Out-Null

    Write-Output $msg.fulfillment #return order

    #set nextSeq for resubscription to the stream 
    $nextSeq = $msg.seq + 1
}

$stream.close()
Write-Host "stream closed"
