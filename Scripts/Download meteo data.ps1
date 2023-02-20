. "$PSScriptRoot\meteo.ps1"

$dataDir = Join-Path $PSScriptRoot ".." "Data" -Resolve

$startDate = New-Object DateTime 1996, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate

while ($downloadDate.AddMonths(1) -lt $currentDate) {
    Get-Meteo-File -year $downloadDate.Year -month $downloadDate.Month -destDir $dataDir
    $downloadDate = $downloadDate.AddMonths(1)
}

$stationFilePath = Join-Path $dataDir "postesSynop.json"
$stationJson = Get-Content $stationFilePath | ConvertFrom-Json
$stations = $stationJson.features | Select-Object -ExpandProperty properties

$searchPattern = Join-Path $dataDir ("synop.*.csv")
$csvFiles = Get-ChildItem -Path $searchPattern | Sort-Object LastWriteTime -Descending

foreach ($csvFile in $csvFiles) {
    Write-Output ("splitting " + $csvFile)
    Split-Meteo-File $stations $csvFile
}

foreach ($stationDir in Get-ChildItem $dataDir -Directory) {
    $stationId = Split-Path $stationDir -Leaf
    Write-Host ("Creating monthly archives for station " + $stationId)
    for ($month = 1; $month -le 12; $month++) {
        Join-Monthly-Files-Into-Archive $stationDir $month
    }
}


$finalDir  = Join-Path $PSScriptRoot ".." "Src" "meteo-history" "public" "data" -Resolve

foreach ($stationDir in Get-ChildItem $dataDir -Directory) {
    $stationId = Split-Path $stationDir -Leaf
    Write-Host ("Copying monthly archives for station " + $stationId + " to final dir")
    $finalStationDir = Join-Path $finalDir $stationId
    foreach ($monthlyArchiveFile in Get-ChildItem $stationDir -Filter *.gz) {
        Copy-File-If-Newer $monthlyArchiveFile $finalStationDir
    }
}
