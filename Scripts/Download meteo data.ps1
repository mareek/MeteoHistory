. "$PSScriptRoot\meteo.ps1"

$destDir = "$PSScriptRoot\..\Data\"

$startDate = New-Object DateTime 2022, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate
while ($downloadDate.AddMonths(1) -lt $currentDate) {
    Get-Meteo-File -year $downloadDate.Year -month $downloadDate.Month -destDir $destDir
    $downloadDate = $downloadDate.AddMonths(1)
}
