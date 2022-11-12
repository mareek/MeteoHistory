. "$PSScriptRoot\meteo.ps1"

$dataDir = Join-Path $PSScriptRoot (Join-Path ".." "Data")
foreach ($stationId in Get-ChildItem $dataDir -Directory) {
    Write-Output ("Creating monthly archives for station " + $stationId)
    $stationDir = Join-Path $dataDir $stationId
    for ($month = 1; $month -lt 13; $month++) {
        Join-Monthly-Files-Into-Archive $stationDir $month
    }
}
