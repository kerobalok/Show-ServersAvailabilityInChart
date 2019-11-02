# reading list of servers from file
$servers = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

# creating empty object
$object = New-Object -TypeName psobject

#  for each server from file create object with properties:
#   - $server - property with name of server  
#   - $ping - array to store ping results
foreach ($server in $servers) {
    $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
    $a = @{$server = @($ping)}
    $object | Add-Member -NotePropertyMembers $a
}
 
# loop for making ping test and add results to property $object.ping
for ($i=0; $i -le 5; $i++) {
    $object.PSObject.Properties | foreach-object {
        $_.Value += Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
    }
}
$object.PSObject.Properties







############################################################################################################################################
#Chart Types - https://docs.microsoft.com/en-us/previous-versions/dd489233(v=vs.140)?redirectedfrom=MSDN
# wyświetla wszystkie właściwości objectu $object.PSObject.Properties
# wyświetlenie konkretnej właściwości objectu #Write-Output $object | select-Object -property "google.com", "onet.pl"
