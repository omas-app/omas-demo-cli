# acknowledge orders
# when an pending order got received, it need to be acknowledged

# event handler for received orders
Register-EngineEvent -SourceIdentifier "OrderReceived" -Action {
    
    # the received order
    $fullfilment = $event.SourceEventArgs.MessageData

    #pending orders need to be acknolage as soon as possible
    if($fullfilment.state -eq "PENDING") {

        $endpoint = "https://api.omas.app/v1/$($fullfilment.name):confirm"

        $body = @{
            ack    = @{}
        }

        $fullfilment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body

        Write-Host "order $($fullfilment.name) acknowledged"

        # we stop the processing and wait for the updated order
        # optional we could already confirm it 
    }
} | Out-Null

# we are using monitor orders method
# it emits an custom event OrderReceived with the Fullfilment 
#.\03-a_monitor-orders.ps1 
.\03-b_poll-orders.ps1




