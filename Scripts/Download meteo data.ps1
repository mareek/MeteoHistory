. "$PSScriptRoot\meteo.ps1"

for ($year = 2022; $year -lt 2023 ; $year++) {
    for ($month = 7; $month -lt 13; $month++) {
        Start-Sleep -Seconds 0.5 # don't DDoS Meteo France's servers

        Get-Meteo-File -year $year -month $month -destDir "$PSScriptRoot\..\Data\"
    }
}
