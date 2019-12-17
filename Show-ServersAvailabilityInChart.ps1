# Inspired by script from https://www.powershellbros.com/building-first-chart-report-powershell/







# reading list of servers from file
$servers = (Get-Content "$PSScriptRoot\servers.txt") -notmatch '^#' 

[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
[void][Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms.DataVisualization')

$Chart = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Chart
$Chart.Size = '960,600'

$ChartArea = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.ChartArea
$ChartArea.AxisX.Title = 'Time'
$ChartArea.AxisY.Title = 'Miliseconds'
$ChartArea.AxisX.Interval = '1'
$ChartArea.AxisX.LabelStyle.Enabled = $true
$ChartArea.AxisX.LabelStyle.Angle = 90
$Chart.ChartAreas.Add($ChartArea) #ta część dodaje obszar wykresu

$Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
$Legend.IsEquallySpacedItems = $True
$Legend.BorderColor = 'Black'
$Chart.Legends.Add($Legend)
$chart.Series["Series1"].LegendText = "#VALX (#VALY)"


# $Chart.Series.Add('ping_response') #ta dodaje serię - chyba tym się mam bawić
# $Chart.Series['ping_response'].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line

foreach ($server in $servers) {
    $Chart.Series.Add($server) #ta dodaje serię - chyba tym się mam bawić
    $Chart.Series[$server].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Line

    $Chart.Legends.Add($server)
    $chart.Series[$server].LegendText = "$server"
}





# creating empty object for measuring servers ping response
$object = New-Object -TypeName psobject

#  for each server from file create object with properties:
#   - $server - property with name of server  
#   - $ping - array to store ping results
foreach ($server in $servers) {
    Write-Host "Processing $Server" -ForegroundColor Green
    $ping = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
    $parameters = @{$server = @($ping)}
    $object | Add-Member -NotePropertyMembers $parameters


    # loop for making ping test and add results to property $object.ping
    for ($i=0; $i -le 5; $i++) {
        $object.PSObject.Properties | foreach-object {
            Write-Host "Pinging $server" -ForegroundColor Green
            $ping_response = Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime
            if($ping_response){
                $_.Value += $Chart.Series[$server].Points.AddXY( (Get-Date -Format "HH:mm:ss"),"$ping_response")
            }
            #$_.Value += Get-CimInstance -Query "select * from win32_pingstatus where Address='$server'" | select-object -Expandproperty ResponseTime   
        }
    }
}



$Title = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Title
$Chart.Titles.Add($Title)
$Chart.Titles[0].Text = 'Servers Availability in Chart'


$Chart.SaveImage($PSScriptRoot + "\Chart.png", "PNG")







############################################################################################################################################
# Chart Types 
#   - https://docs.microsoft.com/en-us/previous-versions/dd489233(v=vs.140)?redirectedfrom=MSDN
#   - https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.datavisualization.charting.seriescharttype?redirectedfrom=MSDN&view=netframework-4.8
# wyświetla wszystkie właściwości objectu $object.PSObject.Properties
# wyświetlenie konkretnej właściwości objectu #Write-Output $object | select-Object -property "google.com", "onet.pl"
