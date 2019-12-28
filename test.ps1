# pętlę for z sekcji pingującej przerobić na while z warunkiem, który będzie zawsze fałszywy, tak aby pętla się zawsze wykonywała
#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()
<################################## -VARIABLES- #####################################>
$interval_delay = 1
<####################################################################################>

$file_content = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# create empty master object to store servers name with ping results
$servers = New-Object  PSObject -Property ([ordered]@{})

# creating subobjects corresponding to name servers and timestamp
$file_content | ForEach-Object {
    $server_name = $_
    if( ($servers.PSObject.Properties | Select-Object -Expand Name) -match $server_name){
        write-host "istnieje" $server_name
    }
    else {
        $servers | Add-Member -NotePropertyMembers ([ordered]@{$server_name=@()})
    }  
}
$servers | Add-Member -NotePropertyMembers ([ordered]@{timestamp=@()})


for ($i=0; $i -le 2; $i++){
    $timestamp = Get-Date -Format G
    $servers.timestamp += $timestamp
    
    # doing ping measurements for every server
    foreach ($server in $servers.PSObject.Properties) {    
        $server_name = $server.Name # to jest problem bo pobiera każdy obiekt typu name i wyknuje na nim dalsze działania

        if ($server_name -ne "timestamp"){
            $ping = 0
            $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server_name'" | select-object -Expandproperty ResponseTime
        
            if ($NULL -eq $ping){
                $ping = 0
            }

            write-host $server_name ":" $ping
            $servers.$server_name += $ping
        }
    }
    Start-Sleep -Seconds $interval_delay
}