. "$PSScriptRoot\meteo.ps1"

$chronoTotal = [System.Diagnostics.Stopwatch]::StartNew()

$dataDir = Join-Path $PSScriptRoot ".." "Data" -Resolve
$archiveDir = Join-Path $dataDir "Archive"
$stationsDir = Join-Path $dataDir "Stations"

$startDate = New-Object DateTime 1996, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate

$PreviousProgressPreference = $ProgressPreference
# We don't want the progress bar to show up for each file downloaded
$ProgressPreference = 'SilentlyContinue'
$chronoDownload = [System.Diagnostics.Stopwatch]::StartNew()
while ($downloadDate.AddMonths(1) -lt $currentDate) {
    Get-Meteo-File -year $downloadDate.Year -month $downloadDate.Month -destDir $archiveDir
    $downloadDate = $downloadDate.AddMonths(1)
}
$chronoDownload.Stop()
$ProgressPreference = $PreviousProgressPreference

$stationFilePath = Join-Path $dataDir "postesSynop.json"
$stationJson = Get-Content $stationFilePath | ConvertFrom-Json
$stations = $stationJson.features | select -ExpandProperty properties

$searchPattern = Join-Path $archiveDir ("synop.*.csv")
$csvFiles = Get-ChildItem -Path $searchPattern | sort LastWriteTime -Descending

$chronoSplit = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($csvFile in $csvFiles) {
    Write-Host ("splitting " + $csvFile)
    Split-Meteo-File $stations $csvFile $stationsDir
}
$chronoSplit.Stop()

$chronoArchive = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($stationDir in Get-ChildItem $stationsDir -Directory) {
    $stationId = Split-Path $stationDir -Leaf
    Write-Host ("Creating monthly archives for station " + $stationId)
    for ($month = 1; $month -le 12; $month++) {
        Join-Monthly-Files-Into-Archive $stationDir $month
    }
}
$chronoArchive.Stop()

$finalDir  = Join-Path $PSScriptRoot ".." "Src" "meteo-history" "public" "data" -Resolve

$chronoCopy = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($stationDir in Get-ChildItem $stationsDir -Directory) {
    $stationId = Split-Path $stationDir -Leaf
    Write-Host ("Copying monthly archives for station " + $stationId + " to final dir")
    $finalStationDir = Join-Path $finalDir $stationId
    foreach ($monthlyArchiveFile in Get-ChildItem $stationDir -Filter *.gz) {
        Copy-File-If-Newer $monthlyArchiveFile $finalStationDir
    }
}
$chronoCopy.Stop()
$chronoTotal.Stop()

Write-Host ("Download : " + $chronoDownload.Elapsed)
Write-Host ("Split    : " + $chronoSplit.Elapsed)
Write-Host ("Archive  : " + $chronoArchive.Elapsed)
Write-Host ("Copy     : " + $chronoCopy.Elapsed)
Write-Host ("Total    : " + $chronoTotal.Elapsed)

