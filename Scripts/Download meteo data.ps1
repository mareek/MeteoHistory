. "$PSScriptRoot\meteo.ps1"

$chronoTotal = [System.Diagnostics.Stopwatch]::StartNew()

$dataDir = Join-Path $PSScriptRoot ".." "Data" -Resolve
$archiveDir = Join-Path $dataDir "Archives"
$stationsDir = Join-Path $dataDir "Stations"
$currentMonthDir = Join-Path $dataDir "CurrentMonth"

New-Directory-If-Not-Exist $dataDir
New-Directory-If-Not-Exist $archiveDir
New-Directory-If-Not-Exist $stationsDir
New-Directory-If-Not-Exist $currentMonthDir

$startDate = New-Object DateTime 1996, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate

# We don't want the progress bar to show up for each file downloaded
$PreviousProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
$chronoDownload = [System.Diagnostics.Stopwatch]::StartNew()
while ($downloadDate.AddMonths(1) -lt $currentDate) {
    Get-Meteo-Archive -year $downloadDate.Year -month $downloadDate.Month -destDir $archiveDir
    $downloadDate = $downloadDate.AddMonths(1)
}
$chronoDownload.Stop()
$ProgressPreference = $PreviousProgressPreference

$stationFilePath = Join-Path $dataDir "postesSynop.json"
$stationJson = Get-Content $stationFilePath | ConvertFrom-Json
$stations = $stationJson.features | select -ExpandProperty properties

$csvFiles = Get-ChildItem -Path $archiveDir | sort LastWriteTime -Descending

$chronoSplit = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($csvFile in $csvFiles) {
    Write-Host ("splitting " + $csvFile)
    Split-Meteo-Archive $stations $csvFile $stationsDir
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

$finalDir = Join-Path $PSScriptRoot ".." "Src" "meteo-history" "public" "data" -Resolve

$chronoCopy = [System.Diagnostics.Stopwatch]::StartNew()
foreach ($stationDir in Get-ChildItem $stationsDir -Directory) {
    $stationId = Split-Path $stationDir -Leaf
    Write-Host ("Copying monthly archives for station " + $stationId + " to final dir")
    $finalStationDir = Join-Path $finalDir $stationId
    foreach ($monthlyArchiveFile in Get-ChildItem $stationDir -Filter "synop.??.csv.gz") {
        Copy-File-If-Newer $monthlyArchiveFile $finalStationDir
    }
}
$chronoCopy.Stop()

$chronoCurrentMonth = [System.Diagnostics.Stopwatch]::StartNew()
# We don't want the progress bar to show up for each file downloaded
$PreviousProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
Get-Meteo-Daily-Files -year $currentDate.Year -month $currentDate.Month  -currentDay $currentDate.Day -destDir $currentMonthDir
$ProgressPreference = $PreviousProgressPreference

$dailyArchiveFile = Join-Daily-Files-Into-Archive -year $currentDate.Year -month $currentDate.Month -currentDay $currentDate.Day -dir $currentMonthDir

Write-Host ("Copying partial current month to final dir")
Copy-File-If-Newer $dailyArchiveFile (Join-Path $finalDir "partial")

Write-Host ("Cleanup previous daily files")
$firstDayOfMonth = Get-Date -Year $currentDate.Year -Month $currentDate.Month -Day 1
$candidateFilesToClean =  (Get-ChildItem $currentMonthDir -Filter "synop.??????*") + (Get-ChildItem (Join-Path $finalDir "partial") -Filter "synop.??????*")
foreach ($dailyFiles in $candidateFilesToClean) {
    $fileDate = Get-Date -Year $dailyFiles.Name.Substring(6, 4) -Month $dailyFiles.Name.Substring(10, 2) -Day 1
    if ($fileDate -lt $firstDayOfMonth) {
        $dailyFiles.Delete()
    }
}

$chronoCurrentMonth.Stop()

$chronoTotal.Stop()

Write-Host ("Download      : " + $chronoDownload.Elapsed)
Write-Host ("Split         : " + $chronoSplit.Elapsed)
Write-Host ("Archive       : " + $chronoArchive.Elapsed)
Write-Host ("Copy          : " + $chronoCopy.Elapsed)
Write-Host ("Current Month : " + $chronoCurrentMonth.Elapsed)
Write-Host ("Total         : " + $chronoTotal.Elapsed)

