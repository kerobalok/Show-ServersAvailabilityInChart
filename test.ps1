#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()

<################################# -PARAMETERS - ####################################>
# Below are parameters with which script can be run. If script will be run without them, it will use they default values.
param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    [ValidateRange(1,600)][int]$interval_delay = 1,
    [ValidateRange(2,100)][int]$number_measurements = 3
)

write-host "interval_delay=" $interval_delay
write-host "number_measurements=" $number_measurements
<####################################################################################>


<################################## -VARIABLES- #####################################>
$FormatEnumerationLimit = 10 #for debuging purposes only. This variable sets number of item displayed on the screen when object is displayed. Default is 4. This variable in production environment can be easely deleted or commented.
<####################################################################################>


$file_content = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# create empty master object to store servers name with ping results
$servers = New-Object  PSObject -Property ([ordered]@{})

# creating subobjects corresponding to name servers and timestamp
$file_content | ForEach-Object {
    $server = $_
    if( ($servers.PSObject.Properties | Select-Object -Expand Name) -match $server){
        write-host "istnieje" $server
    }
    else {
        $servers | Add-Member -NotePropertyMembers ([ordered]@{$server=@()})
    }  
}
$servers | Add-Member -NotePropertyMembers ([ordered]@{timestamp=@()})

do {
    # do ping measurements for every server
    foreach ($server in $servers.PSObject.Properties.Name) {    
        if ($servers.$server.length -eq $number_measurements){
            Write-Debug "usuwanie nadmiarowych elementow z tabicy"
            $servers.$server = $servers.$server[1..$number_measurements]
        }

        # pomiary pingów wykonuj na wszystkich obiektach poza "timestamp"
        if ($server -notmatch "timestamp"){
            [int]$ping = 0
            $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
            
            if ($NULL -eq $ping){
                $ping = 0
            }
            $servers.$server += $ping
        }
    }

    [datetime]$timestamp = Get-Date
    $servers.timestamp += $timestamp
    
    $servers | Format-Table -AutoSize 
    Start-Sleep -Seconds $interval_delay

} while (1 -lt 2) # by regulating this condition you can set if ping measurements should be done forever or by regulated time. 
                  # For forever measurements can be used condition (1 -lt 2)