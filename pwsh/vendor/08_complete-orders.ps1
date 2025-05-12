# complete orders
# when a delivered order gets emitted, we should complete or cancel it
# cancel orders will trigger a charge back on online paid orders

.\07_deliver-orders.ps1 | ForEach-Object {
    
    # the processed order
    $fulfillment = $_

    $endpoint = "https://api.omas.app/v1/$($fulfillment.name):complete"

    #we set the order to completing
    #we could still cancel or settle with different payment channel ourself
    $body = @{} | ConvertTo-Json

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"
    Write-Host "order completing"

    #the order will get finalized with the COMPLETED or SETTLED state
} 



