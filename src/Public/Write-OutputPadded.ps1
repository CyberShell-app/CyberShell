function Write-OutputPadded {
    <#
.SYNOPSIS
   Writes colorized and formatted output to the console.

.DESCRIPTION
   The Write-OutputPadded function writes colorized and formatted output to the console. It supports indentation, centering, and different types of messages (Error, Warning, Success, Information, Data, Debug, Important).

.PARAMETER Text
   The text to be written to the console.

.PARAMETER IndentLevel
   The level of indentation for the output text. Default is 0.

.PARAMETER Width
   The width of the output text. Default is 120.

.PARAMETER Centered
   If set, the output text will be centered.

.PARAMETER isTitle
   If set, the output text will be formatted as a title.

.PARAMETER Type
   The type of the message. It can be one of the following: "Error", "Warning", "Success", "Information", "Data", "Debug", "Important". The type determines the color of the output text.

.EXAMPLE
   Write-OutputPadded -Text "Title" -isTitle -Type "Important"
   Writes the text "Title" formatted as a title and colors it as an Important message.

.EXAMPLE
   Write-OutputPadded -Text "This is a ERROR demo text" -Type "Error" -IndentLevel 2
   Writes the text "This is a ERROR demo text" with an indentation level of 2 and colors it as an Error message.

.EXAMPLE
   Write-OutputPadded -Text "This is a WARNING demo text" -Type "Warning" -IndentLevel 2
   Writes the text "This is a WARNING demo text" with an indentation level of 2 and colors it as a Warning message.

.EXAMPLE
   Write-OutputPadded -Text "This is a SUCCESS demo text" -Type "Success" -IndentLevel 2
   Writes the text "This is a SUCCESS demo text" with an indentation level of 2 and colors it as a Success message.

.EXAMPLE
   Write-OutputPadded -Text "This is a INFORMATION demo text" -Type "Information" -IndentLevel 2
   Writes the text "This is a INFORMATION demo text" with an indentation level of 2 and colors it as an Information message.

.NOTES
   The function uses Write-Host for colorized output formatting.
#>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Write-Host used for colorized output formatting.")]
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