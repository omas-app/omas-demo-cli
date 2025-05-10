# acknowledge orders
# when an pending order got received, it need to be acknowledged

# event handler for received orders
Register-EngineEvent -SourceIdentifier "OrderReceived" -Action {
    
    # the received order
    $fulfillment = $event.SourceEventArgs.MessageData
    
    if($fulfillment.state -eq "RECEIVED") {
        # we asking the user for order accept or decline

        $title = "Order Confirmation"
        $question = "Do you want to accept the order $($fulfillment.name)?"
        $choices = @("&Accept", "&Decline")

        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)

        $endpoint = "https://api.omas.app/v1/$($fulfillment.name):confirm"

        $now = Get-Date

        if ($decision -eq 0) {           
            $body = @{
                 accept    = @{
                    packagingTime = $now.AddSeconds(300).toString("o")  #some estimate
                    deliveryTime =  $now.AddSeconds(3600).toString("o") #some estimate
                 }
            }

            $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body

            Write-Host "order accepted"
            
            # we emit a custom event for script reuse
            New-Event -SourceIdentifier "OrderAccepted" -MessageData $fulfillment | Out-Null
        } else {
            $body = @{
                 decline = "vendor closed"
            }

            $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body

            Write-Host "order declined"
        }
    }
} | Out-Null

# a custom event OrderReceived with the fulfillment will get emitted
.\04_acknowledge-orders.ps1 





