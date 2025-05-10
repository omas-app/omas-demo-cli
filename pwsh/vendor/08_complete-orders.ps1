# complete orders
# when a delivered order gets emitted, we should complete or cancel it
# cancel orders will trigger a charge back on online paid orders

# event handler for delivered orders
Register-EngineEvent -SourceIdentifier "OrderDelivered" -Action {
    
    # the processed order
    $fulfillment = $event.SourceEventArgs.MessageData

    $endpoint = "https://api.omas.app/v1/$($fulfillment.name):complete"

    #we set the order to completing
    #we could still cancel or settle with different payment channel ourself
    $body = @{
    }

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body
    Write-Host "order completing"

    #the order will get finalized with the COMPLETED or SETTLED state
} | Out-Null

# a custom event OrderDelivered with the fulfillment will get emitted
.\07_deliver-orders.ps1 



