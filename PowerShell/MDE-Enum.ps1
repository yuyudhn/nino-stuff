# Enumerate Windows Defender Exclusions via Log Event 5007
# Reference: https://x.com/VakninHai/status/1796628601535652289

$logName = "Microsoft-Windows-Windows Defender/Operational"
$eventID = 5007
$pattern = "HKLM\\SOFTWARE\\Microsoft\\Windows Defender\\Exclusions\\Paths\\([^\s]+)"
$currentUser = whoami

function Test-PathWriteAccess {
    param (
        [string]$path
    )

    try {
        $testFile = [System.IO.Path]::Combine($path, [System.IO.Path]::GetRandomFileName())
        [System.IO.File]::WriteAllText($testFile, "test")
        Remove-Item $testFile -Force
        return $true
    } catch {
        return $false
    }
}

$allEvents = Get-WinEvent -LogName $logName

$filteredEvents = $allEvents | Where-Object { $_.Id -eq $eventID -and $_.Message -match "Exclusions" }

$filteredEvents | ForEach-Object {
    if ($_.Message -match $pattern) {
        $actualPath = $matches[1]
        $writeAccess = Test-PathWriteAccess -path $actualPath
        $accessMessage = if ($writeAccess) { "has write access" } else { "does not have write access" }
        Write-Output "Path: $actualPath"
        Write-Output "$currentUser $accessMessage to $actualPath"
    }
}
