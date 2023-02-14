. "$PSScriptRoot\meteo.ps1"

$destDir = Join-Path $PSScriptRoot (Join-Path ".." "Data")

$startDate = New-Object DateTime 1996, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate

while ($downloadDate.AddMonths(1) -lt $currentDate) {
    Get-Meteo-File -year $downloadDate.Year -month $downloadDate.Month -destDir $destDir
    $downloadDate = $downloadDate.AddMonths(1)
}

$stationFilePath = Join-Path $destDir "postesSynop.json"
$stationJson = Get-Content $stationFilePath | ConvertFrom-Json
$stations = $stationJson.features | Select-Object -ExpandProperty properties

$searchPattern = Join-Path $destDir ("synop.*.csv")
$csvFiles = Get-ChildItem -Path $searchPattern | Sort-Object LastWriteTime -Descending

foreach ($csvFile in $csvFiles) {
    Write-Output ("splitting " + $csvFile)
    Split-Meteo-File $stations $csvFile
}

foreach ($stationId in Get-ChildItem $destDir -Directory) {
    Write-Host ("Creating monthly archives for station " + $stationId)
    $stationDir = Join-Path $destDir $stationId
    for ($month = 1; $month -le 12; $month++) {
        Join-Monthly-Files-Into-Archive $stationDir $month
    }
}
