. "$PSScriptRoot\gzip.ps1"

function New-Directory-If-Not-Exists {
    param ([string]$directory)
    if (-not (Test-Path $directory)) {
        New-Item $directory -ItemType Directory
    }
}

Function Get-Meteo-File {
    Param([int]$year, [int]$month, [string]$destDir, [bool] $overwrite = ($false))
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

    Write-Output ("Downloading " + $url)
    try { 
        Invoke-WebRequest -Uri $url -OutFile $gzFilePath 
        Start-Sleep -Milliseconds 500 # don't DDoS Meteo France's servers
    }
    catch { 
        Write-Output "Error during download :"
        Write-Output $_
        try { Remove-Item $gzFilePath } catch { }
        return 
    }

    Write-Output ("decompressing " + $gzFileName)
    try { 
        Expand-GZip-File $gzFilePath $csvFilePath 
        return $csvFilePath
    }
    catch { 
        Write-Output "Error during decompression :"
        Write-Output $_
        try { Remove-Item $csvFilePath } catch { }
        return 
    }
    finally { Remove-Item $gzFilePath }
}

# This function is horribly slow and should be optimised, it took 90 minutes to process 320 files of ~4MB each
Function Split-Meteo-File {
    Param([string]$srcFile, [string]$destDir, [bool] $overwrite = ($false))
    
    $destDir = Split-Path $srcFile -Parent
    $srcFileName = Split-Path $srcFile -leaf
    $csvFile = Import-Csv $srcFile -Delimiter ';'
    $stations = $csvFile | Select-Object -Property "numer_sta" -Unique
    foreach ($station in $stations) {
        $stationId = $station.numer_sta
        $stationFileDir = Join-Path $destDir $stationId
        $stationFilePath = Join-Path $stationFileDir $srcFileName

        if ($overwrite -or -not (Test-Path($stationFilePath))) {
            New-Directory-If-Not-Exists $stationFileDir
            $stationLines = $csvFile | Where-Object -Property "numer_sta" -EQ -Value $stationId
            $stationLines | Export-Csv $stationFilePath ';' -NoTypeInformation
        }
    }
}