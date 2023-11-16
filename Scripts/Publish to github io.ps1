param([string] $githubIoRootDir)

if (-not $githubIoRootDir) {
    Write-Error "missing githubIoRootDir param"
    exit
}

$githubIoMeteoDir = Join-Path $githubIoRootDir "meteo" "data"
."$PSScriptRoot\Download meteo data.ps1" -finalDir $githubIoMeteoDir

# Update GitHub.io repository
$previousLocation = Get-Location
Set-Location -Path $githubIoRootDir
$currentDate = (Get-Date).ToString("yyyy-MM-dd")
if ((git log --pretty=oneline --max-count=10 | Select-String "\[Auto\] Updated meteo data \($currentDate\)").Count -eq 0) {
    Write-Host "Update github.io site"
    git commit --all -m "[Auto] Updated meteo data ($currentDate)"
    git push
} else {
    Write-Host "github.io site already up to date"
}

Set-Location -path $previousLocation