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
    $destFile = Get-Item $destFilePath 
    if (-not $destFile.Exists -or ($destFile.LastWriteTimeUtc -lt $srcFile.LastWriteTimeUtc)) {
        Copy-Item $srcFile $destFilePath
    }
}

function Get-Meteo-Archive {
    param([int]$year, [int]$month, [string]$destDir, [bool] $overwrite = ($false))
    $gzFileName = "synop." + $year.ToString("0000") + $month.ToString("00") + ".csv.gz"
    $urlBase = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/"
    $url = $urlBase + $gzFileName
    $gzFilePath = Join-Path $destDir $gzFileName

    if ((-not $overwrite) -and (Test-Path $gzFilePath)) {
        return 
    }

    New-Directory-If-Not-Exist $destDir

    Write-Host ("Downloading " + $url)
    try { 
        Invoke-WebRequest -Uri $url -OutFile $gzFilePath 
        Start-Sleep -Milliseconds 500 # don't DDoS Meteo France's servers
    }
    catch { 
        Write-Host "Error during download :"
        Write-Host $_
        try { Remove-Item $gzFilePath } catch { }
        return 
    }
}

function  Split-Meteo-Archive {
    param([object[]]$stations, [string]$srcFile, [string]$destDir, [bool] $overwrite = ($false))
    
    $srcFileName = Split-Path $srcFile -leaf
    foreach ($station in $stations) {
        $stationFileDir = Join-Path $destDir $station.ID
        $stationFilePath = Join-Path $stationFileDir $srcFileName

        if ($overwrite -or -not (Test-Path($stationFilePath))) {
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
    param([string]$dir, [int]$month, [bool] $overwrite = ($false))
    $gzFileName = "synop." + $month.ToString("00") + ".csv.gz"
    $gzFilePath = Join-Path $dir $gzFileName

    $searchPattern = Join-Path $dir ("synop.????" + $month.ToString("00") + ".csv.gz")
    $filesToCompress = Get-ChildItem -Path $searchPattern
    $lastDownloadDate = ($filesToCompress | measure -Property LastWriteTimeUtc -Maximum).Maximum

    if ($overwrite `
        -or (-not (Test-Path $gzFilePath)) `
        -or  (Get-Item $gzFilePath).LastWriteTimeUtc -lt $lastDownloadDate) {
        Write-Host ("Creating archive " + $gzFileName)
        Compress-GZip-Files $filesToCompress  $gzFilePath
    }
}
