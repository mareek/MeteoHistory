. "$PSScriptRoot\gzip.ps1"

function New-Directory-If-Not-Exists {
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
function Get-Meteo-File {
    param([int]$year, [int]$month, [string]$destDir, [bool] $overwrite = ($false))
    $csvFileName = "synop." + $year.ToString("0000") + $month.ToString("00") + ".csv"
    $gzFileName = $csvFileName + ".gz"
    $urlBase = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/"
    $url = $urlBase + $gzFileName
    $gzFilePath = Join-Path $destDir $gzFileName
    $csvFilePath = Join-Path $destDir $csvFileName

    if ((-not $overwrite) -and (Test-Path $csvFilePath)) {
        return 
    }

    New-Directory-If-Not-Exists $destDir

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

    Write-Host ("decompressing " + $gzFileName)
    try { 
        Expand-GZip-File $gzFilePath $csvFilePath 
        return
    }
    catch { 
        Write-Host "Error during decompression :"
        Write-Host $_
        try { Remove-Item $csvFilePath } catch { }
        return 
    }
    finally { Remove-Item $gzFilePath }
}

# This function is horribly slow and should be optimised, it took 90 minutes to process 320 files of ~4MB each
# It is not faster now but at least it doesn't overwrite existing files
function  Split-Meteo-File {
    param([object[]]$stations, [string]$srcFile, [string]$destDir, [bool] $overwrite = ($false))
    
    $destDir = Split-Path $srcFile -Parent
    $srcFileName = Split-Path $srcFile -leaf
    foreach ($station in $stations) {
        $stationFileDir = Join-Path $destDir $station.ID
        $stationFilePath = Join-Path $stationFileDir $srcFileName

        if ($overwrite -or -not (Test-Path($stationFilePath))) {
            if ($null -eq $csvFileContent) {
                $csvFileContent = Import-Csv $srcFile -Delimiter ';'
            }        
            
            New-Directory-If-Not-Exists $stationFileDir
            $stationLines = $csvFileContent | Where-Object -Property "numer_sta" -EQ -Value $station.ID
            $stationLines | Export-Csv $stationFilePath ';' -NoTypeInformation
        }
    }
}

function Join-Monthly-Files-Into-Archive {
    param([string]$dir, [int]$month, [bool] $overwrite = ($false))
    $gzFileName = "synop." + $month.ToString("00") + ".csv.gz"
    $gzFilePath = Join-Path $dir $gzFileName

    if ((-not $overwrite) -and (Test-Path $gzFilePath)) {
        return 
    }

    $searchPattern = Join-Path $dir ("synop.*" + $month.ToString("00") + ".csv")
    $filesToCompress = Get-ChildItem -Path $searchPattern
    Write-Host ("Creating archive " + $gzFileName)
    Compress-GZip-Files $filesToCompress  $gzFilePath
}
