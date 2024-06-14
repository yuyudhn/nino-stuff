# Enumerate Windows Defender Exclusions via Log Event 5007
# Reference: https://x.com/VakninHai/status/1796628601535652289

$logName = "Microsoft-Windows-Windows Defender/Operational"
$eventID = 5007
$pattern = "HKLM\\SOFTWARE\\Microsoft\\Windows Defender\\Exclusions\\Paths\\(.+)"

$allEvents = Get-WinEvent -LogName $logName
$filteredEvents = $allEvents | Where-Object { $_.Id -eq $eventID -and $_.Message -match "Exclusions" }

$filteredEvents | ForEach-Object {
    if ($_.Message -match $pattern) {
        $actualPath = $matches[1].Trim('"')
        Write-Output "Path: $actualPath"
    }
}
