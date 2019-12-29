
#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()
# zmienic foreach ($server in $servers.PSObject.Properties) na $servers | Get-Member -MemberType NoteProperty | Select-Object -Expand Name    i zaraz potem w całym foreach zamienić zmienną $server_address na samą $server z warunku foreach
<################################## -VARIABLES- #####################################>
$interval_delay = 1 #interval in seconds between finish and start another cycle of ping measurements.
$FormatEnumerationLimit = 10 #for debuging purposes only. This variable sets number of item displayed on the screen when object is displayed. Default is 4. This variable in production environment can be easely deleted or commented.
$number_measurements = 5
<####################################################################################>

$file_content = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# create empty master object to store servers name with ping results
$servers = New-Object  PSObject -Property ([ordered]@{})

# creating subobjects corresponding to name servers and timestamp
$file_content | ForEach-Object {
    $server_address = $_
    if( ($servers.PSObject.Properties | Select-Object -Expand Name) -match $server_address){
        write-host "istnieje" $server_address
    }
    else {
        $servers | Add-Member -NotePropertyMembers ([ordered]@{$server_address=@()})
    }  
}
$servers | Add-Member -NotePropertyMembers ([ordered]@{timestamp=@()})

do {
    
    # do ping measurements for every server
    foreach ($server in $servers.PSObject.Properties) {    
        $server_address = $server.Name # to jest problem bo pobiera każdy obiekt typu name i wyknuje na nim dalsze działania
        
        if ($servers.$server_address.length -eq $number_measurements){
            Write-Debug "usuwanie nadmiarowych elementow z tabicy"
            $servers.$server_address = $servers.$server_address[1..$number_measurements]
        }

        # pomiary pingów wykonuj na wszystkich obiektach poza "timestamp"
        if ($server_address -notmatch "timestamp"){
            $ping = 0
            $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server_address'" | select-object -Expandproperty ResponseTime
            
            if ($NULL -eq $ping){
                $ping = 0
            }
            $servers.$server_address += $ping
        }
    }

    $timestamp = Get-Date -Format G
    $servers.timestamp += $timestamp
    
    $servers | Format-Table -AutoSize
    Start-Sleep -Seconds $interval_delay

} while (1 -lt 2) #by regulating this condition you can set if ping measurements should be done forever or by regulated time. For forever measurements can be used condition (1 -lt 2)