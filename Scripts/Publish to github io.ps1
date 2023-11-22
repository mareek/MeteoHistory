param([string] $githubIoRootDir)

if (-not $githubIoRootDir) {
    Write-Error "missing githubIoRootDir param"
    exit
}

$githubIoMeteoDir = Join-Path $githubIoRootDir "meteo" "data"

$previousLocation = Get-Location
Set-Location -Path $githubIoRootDir
$currentDate = Get-Date
if ((git log --pretty=oneline --max-count=10 | Select-String "\[Auto\] Updated meteo data \($($currentDate.ToString("yyyy-MM-dd"))\)").Count -eq 0) {
    ."$PSScriptRoot\Download meteo data.ps1" -finalDir $githubIoMeteoDir

    # Update GitHub.io repository
    Write-Host "Update github.io site"
    git add .
    git commit --all -m "[Auto] Updated meteo data ($($currentDate.ToString("yyyy-MM-dd")))"
    git push
}
else {
    Write-Host "github.io site already up to date"
}

Set-Location -path $previousLocation