# deliver orders
# when a processed order gets emitted, we need to deliver it



# a custom event OrderAccepted with the fulfillment will get emitted
.\06_process-orders.ps1 | ForEach-Object {
    
    # the processed order
    $fulfillment = $_

    $endpoint = "https://api.omas.app/v1/$($fulfillment.name):deliver"

    #we simulate the deliver step
    
    #delay pickup
    Write-Host "order delay pickup simulation"
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #optional start shipping

    $now = Get-Date

    #start delivering (last mile delivery)
    $body = @{
        delivery = @{
            time = $now.AddSeconds(300).toString("o") #new delivery estimate
        }
        completed = $false
    } | ConvertTo-Json

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"
    Write-Host "order delivering"

    #delay delivery
    Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

    #order is delivered
    $body = @{
        delivery = @{
            time = (Get-Date -Format "o") #the delivery time
        }
        completed = $true
    } | ConvertTo-Json

    $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"
    Write-Host "order delivered"

    #we emit a custom event for script reuse
    New-Event -SourceIdentifier "OrderDelivered" -MessageData $fulfillment | Out-Null   
    
    #we return the delivered order 
    Write-Output  $fulfillment
}






