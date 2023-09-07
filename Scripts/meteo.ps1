. "$PSScriptRoot\gzip.ps1"

function New-Directory-If-Not-Exist {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param ([string]$directory)
    if (-not (Test-Path $directory)) {
        New-Item $directory -ItemType Directory
    }
}

function Copy-File-If-Newer {
    param ([System.IO.FileInfo]$srcFile, [string]$destDir)
    $fileName = Split-Path $srcFile -leaf
    $destFilePath = Join-Path $destDir $fileName
    if (-not (Test-Path $destFilePath) -or ((Get-Item $destFilePath).LastWriteTimeUtc -lt $srcFile.LastWriteTimeUtc)) {
        Copy-Item $srcFile $destFilePath
    }
}

function Safe-Download {
    param([string]$fileName, [string]$baseUrl, [string]$destDir)
    
    $destFilePath = Join-Path $destDir $fileName
    if (Test-Path $destFilePath) {
        return
    }

    $url = $urlBase + $fileName
    Write-Host ("Downloading " + $url)
    try { 
        Invoke-WebRequest -Uri $url -OutFile $destFilePath 
        Start-Sleep -Milliseconds 500 # don't DDoS Meteo France's servers
    }
    catch { 
        Write-Host "Error during download :"
        Write-Host $_
        if (Test-Path $destFilePath) {
            Remove-Item $destFilePath
        }
        return 
    }
}

function Join-Files-Into-Archive {
    param([string]$searchPattern, [string]$archiveFilePath)
    $filesToCompress = Get-ChildItem -Path $searchPattern
    $lastDownloadDate = ($filesToCompress | measure -Property LastWriteTimeUtc -Maximum).Maximum
    
    if ((-not (Test-Path $archiveFilePath)) -or (Get-Item $archiveFilePath).LastWriteTimeUtc -lt $lastDownloadDate) {
        Write-Host ("Creating archive " + (Split-Path $archiveFilePath -Leaf))
        Compress-GZip-Files $filesToCompress  $archiveFilePath
    }
}

function Get-Meteo-Archive {
    param([int]$year, [int]$month, [string]$destDir)
    $urlBase = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/"
    $gzFileName = "synop." + $year.ToString("0000") + $month.ToString("00") + ".csv.gz"
    Safe-Download -fileName $gzFileName -urlBase $urlBase -destDir $destDir
}

function Split-Meteo-Archive {
    param([object[]]$stations, [string]$srcFile, [string]$destDir)
    
    $srcFileName = Split-Path $srcFile -leaf
    foreach ($station in $stations) {
        $stationFileDir = Join-Path $destDir $station.ID
        $stationFilePath = Join-Path $stationFileDir $srcFileName

        if (-not (Test-Path($stationFilePath))) {
            if ($null -eq $csvFileContent) {
                $unzipedSrcFile = $srcFile + ".tmp"
                Expand-GZip-File $srcFile $unzipedSrcFile
                $csvFileContent = Get-Content -Path $unzipedSrcFile | group -AsHashTable -Property { $_.Split(";")[0] }
                Remove-Item $unzipedSrcFile
            }
            
            New-Directory-If-Not-Exist $stationFileDir
            if ($csvFileContent.ContainsKey($station.ID)) {
                Out-GZip-File $csvFileContent[$station.ID] $stationFilePath
            }
            else {
                #Create an empty file to speed up further passes
                Out-GZip-File "" $stationFilePath
            }
        }
    }
}

function Join-Monthly-Files-Into-Archive {
    param([string]$dir, [int]$month)
    $gzFileName = "synop." + $month.ToString("00") + ".csv.gz"
    $searchPattern = Join-Path $dir ("synop.????" + $month.ToString("00") + ".csv.gz")
    Join-Files-Into-Archive -searchPattern $searchPattern -archiveFilePath (Join-Path $dir $gzFileName)
}

function Get-Meteo-Daily-Files {
    param ([int]$year, [int]$month, [int]$currentDay, [string]$destDir)
    # https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/synop.2022112418.csv
    $urlBase = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/"
    $hours = 0, 3, 6, 9, 12, 15, 18, 21
    for ($day = 1; $day -lt $currentDay; $day++) {
        foreach ($hour in $hours) {
            $fileName = "synop." + $year.ToString("0000") + $month.ToString("00") + $day.ToString("00") + $hour.ToString("00") + ".csv"
            Safe-Download -fileName $fileName -urlBase $urlBase -destDir $destDir
        }            
    }
}

function Join-Daily-Files-Into-Archive {
    param ([int]$year, [int]$month, [int]$currentDay, [string]$dir)
    $archiveFileName = "synop." + $year.ToString("0000") + $month.ToString("00") + ".csv.gz"
    $archiveFilePath = Join-Path $dir $archiveFileName
    $searchPattern = Join-Path $dir ("synop." + $year.ToString("0000") + $month.ToString("00") + "????.csv")
    Join-Files-Into-Archive -searchPattern $searchPattern -archiveFilePath $archiveFilePath
    Get-Item $archiveFilePath
}