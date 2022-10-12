. "$PSScriptRoot\meteo.ps1"

$destDir = Join-Path $PSScriptRoot (Join-Path ".." "Data")

$startDate = New-Object DateTime 1996, 1, 1
$currentDate = Get-Date
$downloadDate = $startDate
while ($downloadDate.AddMonths(1) -lt $currentDate) {
    $csvFilePath = Get-Meteo-File -year $downloadDate.Year -month $downloadDate.Month -destDir $destDir
    if ($null -ne $csvFilePath) {
        Write-Output ("splitting " + $csvFilePath)
        Split-Meteo-File $csvFilePath
    }
    $downloadDate = $downloadDate.AddMonths(1)
}
