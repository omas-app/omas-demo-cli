# acknowledge orders
# when an pending order got received, it need to be acknowledged

# we are can use monitor or poll method to modified receive orders 
#.\03-a_monitor-orders.ps1 | ForEach-Object {
.\03-b_poll-orders.ps1 | ForEach-Object {
     # the received order
    $fulfillment = $_

    #pending orders need to be acknowledged as soon as possible
    if($fulfillment.state -eq "PENDING") {

        $endpoint = "https://api.omas.app/v1/$($fulfillment.name):confirm"

        $body = @{
            ack    = @{}
        } | ConvertTo-Json

        try  {
            $fulfillment = Invoke-RestMethod -Authentication Bearer -Token $accessToken -Uri $endpoint -Method Post -Body $body -ContentType "application/json"

            Write-Host "order $($fulfillment.name) acknowledged"
        } catch {
            Write-Host "order ack error: $($_.Exception.Message)"
        }

        # we stop the processing and wait for the updated order
        # optional we could already confirm it 
    } else {
        #return to caller
        Write-Output  $fulfillment
    }
}




