. "$PSScriptRoot\gzip.ps1"

Function Get-Meteo-File {
    Param([Int]$year, [Int]$month, [String]$destDir, [Boolean] $overWrite = ($false))
    $csvFileName = "synop." + $year.ToString("0000") + $month.ToString("00") + ".csv"
    $gzFileName = $csvFileName + ".gz"
    $urlBase = "https://donneespubliques.meteofrance.fr/donnees_libres/Txt/Synop/Archive/"
    $url = $urlBase + $gzFileName
    $gzFilePath = $destDir + $gzFileName
    $csvFilePath = $destDir + $csvFileName

    if ((-not $overWrite) -and (Test-Path($csvFilePath))) {
        return
    }

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
    try { Expand-GZip-File $gzFilePath $csvFilePath }
    catch { 
        Write-Output "Error during decompression :"
        Write-Output $_
        try { Remove-Item $csvFilePath } catch { }
        return 
    }
    finally { Remove-Item $gzFilePath }
}
