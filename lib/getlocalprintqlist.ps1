# Here is a PowerShell script that queries the
# local print queues and returns an identifier
# for each print queue found on the system:

# Rxecute it in a PowerShell prompt to get a list of
# local print queues with their identifiers, names,
# server names, and queue names.

# getlocalprintqs.ps1

# Import the required namespace for print management
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class PrintSystem {
    [DllImport("winspool.drv", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern bool EnumPrinters(
        int Flags,
        string Name,
        uint Level,
        IntPtr pPrinterEnum,
        uint cbBuf,
        out uint pcbNeeded,
        out uint pcReturned);
}
"@ -Language CSharp

# Define printer enumeration flag values
$PRINTER_ENUM_LOCAL = 2

# Query the local printers
$bufferSize = 0
$numberOfPrinters = 0

[void][PrintSystem]::EnumPrinters($PRINTER_ENUM_LOCAL, [NullString]::Value, 2, [IntPtr]::Zero, 0, [ref] $bufferSize, [ref] $numberOfPrinters)

$buffer = [Marshal]::AllocHGlobal($bufferSize)
$printersFound = [PrintSystem]::EnumPrinters($PRINTER_ENUM_LOCAL, [NullString]::Value, 2, $buffer, $bufferSize, [ref] $bufferSize, [ref] $numberOfPrinters)

if ($printersFound) {
    $printerInfo2Type = [System.Runtime.InteropServices.Marshal]::GetTypeFromCLSID("{A84CBD9F-984B-3A89-A845-A3366C0D6C48}")
    for ($i = 0; $i -lt $numberOfPrinters; $i++) {
        $printerInfo = [System.Runtime.InteropServices.Marshal]::PtrToStructure($buffer, $printerInfo2Type)
        [PSCustomObject]@{
            Identifier = $i + 1
            PrinterName = $printerInfo.pPrinterName
            ServerName = $printerInfo.pServerName
            QueueName = $printerInfo.pShareName
        }

        $buffer = [System.IntPtr]($buffer.ToInt64() + [System.Runtime.InteropServices.Marshal]::SizeOf($printerInfo2Type))
    }
}

[Marshal]::FreeHGlobal($buffer)
