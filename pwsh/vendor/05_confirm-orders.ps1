# acknowledge orders
# when an acknowledged order got received, it need to be accepted or declined

.\04_acknowledge-orders.ps1  | ForEach-Object {
    # the received order
    $fulfillment = $_

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
            } | ConvertTo-Json

            $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"

            Write-Host "order accepted"
            
            # we emit a custom event
            New-Event -SourceIdentifier "OrderAccepted" -MessageData $fulfillment | Out-Null
        
            #we return the accepted order
            Write-Output  $fulfillment
        } else {
            $body = @{
                 decline = "vendor closed"
            } | ConvertTo-Json

            $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"

            Write-Host "order declined"
        }
    } else {
        #we ignore all other state        
    }
}




