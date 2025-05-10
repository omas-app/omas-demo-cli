# process orders
# when a accepted order gets emitted, we need to process it

# event handler for accepted orders
Register-EngineEvent -SourceIdentifier "OrderAccepted" -Action {
    
    # the accepted order
    $fulfillment = $event.SourceEventArgs.MessageData

    $endpoint = "https://api.omas.app/v1/$($fulfillment.name):process"

    #we simulate the process step
    
    #delay
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #start processing
    $body = @{
        completed = $false
    }

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body
    Write-Host "order processing"

    #optional transmit state of sourcing, assembly and packaging

    #delay process
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #stop processing
    $body = @{
        completed = $true
    }

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body
    Write-Host "order processed"

    #we emit a custom event for script reuse
    New-Event -SourceIdentifier "OrderProcessed" -MessageData $fulfillment | Out-Null    
} | Out-Null

# a custom event OrderAccepted with the fulfillment will get emitted
.\05_confirm-orders.ps1 





