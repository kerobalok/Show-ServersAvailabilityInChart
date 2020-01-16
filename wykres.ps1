$Process = Get-Process | Sort-Object WS -Descending | Select-Object -First 10


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms.DataVisualization


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


#$Chart.Series['Series1'].Points.DataBindXY($Process.Name, $Process.WS)
# $a = $servers.PSObject.Properties | Where-Object -property Name -eq "facebook.com" | Select-Object -ExpandProperty Name
# $b = $servers.PSObject.Properties | Where-Object -property Name -eq "timestamp" | Select-Object -ExpandProperty Value
#$a = $servers.PSObject.Properties.Name
#$servers.PSObject.Properties.Name | Where-Object {$_ -notlike "timestamp"} #nazwy podobiektów (serwerów), bez podobiektu timestamp


# $x = $servers.PSObject.Properties | Where-Object -property Name -eq "timestamp" | Select-Object -ExpandProperty Value #zawartość timestamp
# $y = $servers.PSObject.Properties | Where-Object {($_.Name -notlike "timestamp") -and ($_.Name -like "gmail.com")} | Select-Object -ExpandProperty Value # zawartość pingów z wyjątkiem podobiektu timestamp


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