# deliver orders
# when a processed order gets emitted, we need to deliver it

# event handler for processed orders
Register-EngineEvent -SourceIdentifier "OrderProcessed" -Action {
    
    # the processed order
    $fullfilment = $event.SourceEventArgs.MessageData

    $endpoint = "https://api.omas.app/v1/$($fullfilment.name):deliver"

    #we simulate the deliver step
    
    #delay pickup
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #optional start shipping

    $now = Get-Date

    #start delivering (last mile delivery)
    $body = @{
        delivery = @{
            time = $now.AddSeconds(300).toString("o") #new delivery estimate
        }
        completed = $false
    }

    $fullfilment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body
    Write-Host "order delivering"

    #delay delivery
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #order is delivered
    $body = @{
        delivery = @{
            time = (Get-Date -Format "o") #the delivery time
        }
        completed = $true
    }

    $fullfilment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body
    Write-Host "order delivered"

    #we emit a custom event for script reuse
    New-Event -SourceIdentifier "OrderDelivered" -MessageData $fullfilment | Out-Null    
} | Out-Null

# a custom event OrderAccepted with the Fullfilment will get emitted
.\06_process-orders.ps1 





