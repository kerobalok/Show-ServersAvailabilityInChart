#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()

<################################# -PARAMETERS - ####################################>
# Below are parameters with which script can be run. If script will be run without them, it will use they default values.
param(
    [ValidateRange(1,600)][int]$interval_delay = 1,
    [ValidateRange(2,100)][int]$number_measurements = 4
)
<####################################################################################>

<################################## -VARIABLES- #####################################>
$FormatEnumerationLimit = 10 #for debuging purposes only. This variable sets number of item displayed on the screen when object is displayed. Default is 4. This variable in production environment can be easely deleted or commented.
<####################################################################################>


# reading servers from file
$file_content = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# create empty master object to store servers name with ping results
$servers = New-Object  PSObject -Property ([ordered]@{})

# creating subobjects storing servers names
$file_content | ForEach-Object {
    $server = $_
    if( ($servers.PSObject.Properties | Select-Object -Expand Name) -match $server){
        write-host "istnieje" $server
    }
    else {
        $servers | Add-Member -NotePropertyMembers ([ordered]@{$server=@()})
    }  
}

# creating subobject storing timestamp
$servers | Add-Member -NotePropertyMembers ([ordered]@{timestamp=@()})

# loop "do while" doing measurements
do {
    # do ping measurements for every server from $servers object
    foreach ($server in $servers.PSObject.Properties.Name) {
        # checking number of measurements stored under servers subobjects and delete unnesesary results (results that exceed $number_measurements)    
        if ($servers.$server.length -eq $number_measurements){
            Write-Debug "usuwanie nadmiarowych elementow z tabicy"
            $servers.$server = $servers.$server[1..$number_measurements]
        }

        # doing ping measurements for every server address stored in $server subobject excluding subobject named "timestamp"
        if ($server -notmatch "timestamp"){
            [int]$ping = 0
            $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
            
            # if server not respondig to ping, replace null value with 0
            if ($NULL -eq $ping){
                $ping = -1
            }
            
            #add ping result to array stored under $server subobject, for example facebook.com@{10,11, itd.}
            $servers.$server += $ping
        }
    }

    [datetime]$timestamp = Get-Date
    $servers.timestamp += $timestamp
    
    $servers | Format-Table -AutoSize 
    Start-Sleep -Seconds $interval_delay

} while (1 -lt 2) # by regulating this condition you can set if ping measurements should be done forever or by regulated time. 
                  # For forever measurements you can use condition (1 -lt 2)