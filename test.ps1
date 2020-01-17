#sprawdzanie czy mamy do czynienia ze zmienną, tablicą, obiektem można sprawdzić poprzez $cos_do_sprawdzenia.gettype()

#-------------------------------------------------------------------------------------------------------------------------------------------------
#region ENTRY REQUIREMENTS (open region Ctrl+K Ctrl+8, close Ctrl+K Ctrl+8)
#-------------------------------------------------------------------------------------------------------------------------------------------------
################################# -PARAMETERS - ####################################
# Below are parameters with which script can be run. If script will be run without them, it will use they default values.
param(
    [ValidateRange(1,600)][int]$interval_delay = 1,
    [ValidateRange(2,100)][int]$number_measurements = 4
)
####################################################################################

################################## -VARIABLES- #####################################
$FormatEnumerationLimit = 10 #for debuging purposes only. This variable sets number of item displayed on the screen when object is displayed. Default is 4. This variable in production environment can be easely deleted or commented.
####################################################################################

########################## - TYPES NEEDED TO MAKE CHART - ##########################
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization
####################################################################################

################################## - FUNCTIONS - ###################################
function script:New-Chart {
    param ([PSCustomObject]$servers)

    $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
    $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
    $Series = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $Series2 = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $Series3 = New-Object -TypeName System.Windows.Forms.DataVisualization.Charting.Series
    $ChartTypes = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]

    $Series.ChartType = $ChartTypes::Line
    $Series2.ChartType = $ChartTypes::Line
    $Series3.ChartType = $ChartTypes::Line

    $Chart.Series.Add($Series)
    $Chart.Series.Add($Series2)
    $Chart.Series.Add($Series3)
    $Chart.ChartAreas.Add($ChartArea)

    $Chart.Series['Series1'].Points.DataBindXY($servers.timestamp, $servers."facebook.com")
    $Chart.Series['Series2'].Points.DataBindXY($servers.timestamp, $servers."gmail.com")
    $Chart.Series['Series3'].Points.DataBindXY($servers.timestamp, $servers."10.0.5.1")

    $Chart.Width = 700
    $Chart.Height = 400
    $Chart.Left = 10
    $Chart.Top = 10
    $Chart.BackColor = [System.Drawing.Color]::White
    $Chart.BorderColor = 'Black'
    $Chart.BorderDashStyle = 'Solid'

    $ChartTitle = New-Object System.Windows.Forms.DataVisualization.Charting.Title
    $ChartTitle.Text = 'Servers Availability'
    $Font = New-Object System.Drawing.Font @('Microsoft Sans Serif','12', [System.Drawing.FontStyle]::Bold)
    $ChartTitle.Font =$Font
    $Chart.Titles.Add($ChartTitle)

    $Legend = New-Object System.Windows.Forms.DataVisualization.Charting.Legend
    $Legend.IsEquallySpacedItems = $True
    $Legend.BorderColor = 'Black'
    $Chart.Legends.Add($Legend)
    $chart.Series["Series1"].LegendText = $servers.PSObject.Properties | Where-Object -property Name -eq "facebook.com" | Select-Object -ExpandProperty Name
    $chart.Series["Series2"].LegendText = $servers.PSObject.Properties | Where-Object -property Name -eq "gmail.com" | Select-Object -ExpandProperty Name
    $chart.Series["Series3"].LegendText = $servers.PSObject.Properties | Where-Object -property Name -eq "10.0.5.1" | Select-Object -ExpandProperty Name

    $Chart.SaveImage($PSScriptRoot + "\wykres.png", "PNG")
}
####################################################################################
#-------------------------------------------------------------------------------------------------------------------------------------------------
#endregion ENTRY REQUIREMENTS
#-------------------------------------------------------------------------------------------------------------------------------------------------


#-------------------------------------------------------------------------------------------------------------------------------------------------
#region MAIN CODE (open region Ctrl+K Ctrl+8, close Ctrl+K Ctrl+8)
#-------------------------------------------------------------------------------------------------------------------------------------------------
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
    New-Chart $servers
    Start-Sleep -Seconds $interval_delay

} while (1 -lt 2) # by regulating this condition you can set if ping measurements should be done forever or by regulated time. For forever measurements you can use condition (1 -lt 2)
#-------------------------------------------------------------------------------------------------------------------------------------------------
#endregion MAIN CODE
#-------------------------------------------------------------------------------------------------------------------------------------------------