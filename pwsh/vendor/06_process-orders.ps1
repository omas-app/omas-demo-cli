# process orders
# when a accepted order gets emitted, we need to process it

.\05_confirm-orders.ps1 | ForEach-Object {
    # the accepted order
    $fulfillment = $_

    if($fulfillment.state -eq "ACCEPTED") {

        $endpoint = "https://api.omas.app/v1/$($fulfillment.name):process"

        #we simulate the process step
        Write-Host "order idle simulation"
        
        #delay
        Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

        #start processing
        $body = @{
            completed = $false
        } | ConvertTo-Json

        $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"
        Write-Host "order processing"

        #optional transmit state of sourcing, assembly and packaging

        #delay process
        Start-Sleep -Seconds (Get-Random -Minimum 5 -Maximum 30)

        #stop processing
        $body = @{
            completed = $true
        } | ConvertTo-Json

        $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"
        Write-Host "order processed"

        #we emit a custom event for script reuse
        New-Event -SourceIdentifier "OrderProcessed" -MessageData $fulfillment | Out-Null   
    
        #we return the processed order 
        Write-Output  $fulfillment
    } else {
        #we ignore other states       
    }
}




