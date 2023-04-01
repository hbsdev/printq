# You can use the output from the getlocalprintqlist script as
# an input for this one. For example, if the previous script
# outputted a printer with an Identifier of 1 and a PrinterName
# of "Microsoft Print to PDF", you can execute this script as follows:

# .\getprintqstate.ps1 -PrinterName "Microsoft Print to PDF"

# The script will return the state of the print queue, such as "Running", "Paused", or other detailed statuses.

param (
    [Parameter(Mandatory = $true)]
    [string]$PrinterName
)

function Get-PrintQueueStatus {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Printer
    )

    try {
        $printQueue = New-Object -TypeName System.Printing.PrintQueue -ArgumentList (New-Object -TypeName System.Printing.LocalPrintServer), $Printer

        $queueStatus = $printQueue.QueueStatus
        if ($queueStatus -eq [System.Printing.PrintQueueStatus]::None) {
            return "Running"
        } else {
            $statusString = ""
            $enumValues = [System.Enum]::GetValues($queueStatus.GetType())
            foreach ($value in $enumValues) {
                if ($queueStatus.HasFlag($value)) {
                    $statusString += "$($value.ToString()), "
                }
            }
            return $statusString.TrimEnd(', ')
        }
    }
    catch {
        Write-Error "Failed to get the print queue status for '$Printer'."
        return $null
    }
}

$queueStatus = Get-PrintQueueStatus -Printer $PrinterName
if ($null -ne $queueStatus) {
    [PSCustomObject]@{
        PrinterName = $PrinterName
        QueueStatus = $queueStatus
    }
}
