function Write-OutputPadded {


    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Text,

        [Parameter(Position = 1, Mandatory = $false)]
        [int]$IndentLevel = 0,

        [Parameter(Mandatory = $false)]
        [int]$Width = 120,

        [Parameter(Mandatory = $false)]
        [switch]$Centered = $false,

        [Parameter(Mandatory = $false)]
        [switch]$isTitle = $false,

        [Parameter(Mandatory = $false)]
        [ValidateSet("Error", "Warning", "Success", "Information", "Data", "Debug", "Important")]
        [string]$Type
    )

    $indentation = $IndentLevel * 4
    $effectiveWidth = $Width - $indentation
    $lines = $Text -split '\r?\n'
    $wrappedLines = @()

    foreach ($line in $lines) {
        if ($line.Length -le $effectiveWidth) {
            $wrappedLines += $line
        }
        else {
            $wrappedLines += $line -replace "(?<=\S{$effectiveWidth})(\S)", "`$1`n"
        }
    }

    if ($isTitle) {
        $topBorder = "=" * $Width
        Write-Host $topBorder
    }

    foreach ($line in $wrappedLines) {
        $linePadding = ""
        if ($Centered -or $isTitle) {
            $totalPadding = $Width - $line.Length
            $leftPadding = [math]::Floor($totalPadding / 2)
            $linePadding = ' ' * ($leftPadding + $indentation)
            #$line = $line.PadRight($Width - $leftPadding, ' ')
        }
        else {
            $linePadding = ' ' * $indentation
            # Remove right padding if not a title
            if (!$isTitle) {
                $line = $line.TrimEnd(' ')
            }
        }

        Write-Host -NoNewline $linePadding

        switch ($Type) {

            "Error" {
                Write-Host $line -ForegroundColor Red
            }
            "Success" {
                Write-Host $line -ForegroundColor Green
            }
            "Information" {
                Write-Host $line -ForegroundColor Cyan
            }
            "Data" {
                Write-Host $line -ForegroundColor Magenta
            }
            "Debug" {
                Write-Host $line -ForegroundColor DarkGray
            }
            "Warning" {
                Write-Host $line -ForegroundColor Black -BackgroundColor DarkYellow -NoNewline
                Write-Host " "
            }
            "Important" {
                Write-Host $line -ForegroundColor White -BackgroundColor DarkRed -NoNewline
                Write-Host " "
            }
            default { Write-Host $line }
        }
    }

    if ($isTitle) {
        $bottomBorder = "-" * $Width
        Write-Host $bottomBorder
    }
}