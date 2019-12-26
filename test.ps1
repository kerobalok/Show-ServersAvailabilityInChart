# pętlę for z sekcji pingującej przerobić na while z warunkiem, który będzie zawsze fałszywy, tak aby pętla się zawsze wykonywała
<################################## -VARIABLES- #####################################>
$interval_delay = 1
<####################################################################################>

#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()
$file_content = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# create empty master object to store servers name with ping results
$servers = New-Object PSObject -Property @{}

# for every server readed from file checking if object named as server name exist in main object, and if not creating one
$file_content | ForEach-Object {
    $server_name = $_
    if( ($servers.PSObject.Properties | Select-Object -Expand Name) -match $server_name){
        write-host "istnieje" $server_name
    }
    else {
        $servers | Add-Member -NotePropertyMembers @{$server_name=@()}
    }
}

# doing ping measurements for every server
for ($i=0; $i -lt 3; $i++){
    foreach ($server in $servers.PSObject.Properties) {
        $server_name = $server.Name
        $ping = 0
        
        $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server_name'" | select-object -Expandproperty ResponseTime
        
        if ($NULL -eq $ping){
            $ping = 0
        }

        write-host $server_name ": " $ping
        
        #write-host $server_name":" $ping "ms"
        $servers.$server_name += $ping
    }
    write-host "start przerwy"
    Start-Sleep -Seconds $interval_delay
    write-host "koniec przerwy"
}

$servers
#Remove-Variable $servers
