##############################################################################
# Install this script by putting the following in your
# Microsoft.Powershell_profile.ps1 file:
#
#     Import-Module 'C:\path\to\module\TfsHandy.psm1'
#
# Then you can use the commands Show-TfsDiff (mydf) and Show-TfsStatus
#  (myst) to get colorized and prettified output from your Team
# Foundation Server.
##############################################################################
# Write-Host variants ########################################################
##############################################################################
function Print(
    [string]$line
) {
    Write-Host $line -NoNewline
}

function PrintCol(
    [string]$line,
    [string]$col
) {
    Write-Host $line -ForegroundColor $col -NoNewline
}

function PrintCyan(
    [string]$line
) {
    PrintCol $line Cyan
}

function PrintGray(
    [string]$line
) {
    PrintCol $line Gray
}

function PrintGreen(
    [string]$line
) {
    PrintCol $line Green
}

function PrintRed(
    [string]$line
) {
    PrintCol $line 6
}

function PrintWhite(
    [string]$line
) {
    PrintCol $line White
}

##############################################################################
# TFS Utility ################################################################
##############################################################################

function CountChanges([string]$fname, [string]$versionOpt) {
    #requires -version 2
    $changes = $(0, 0)
    tf diff $fname $versionOpt /noprompt | ForEach {
        if ($_ -match "^\+[^\+]") {
            $changes[0] += 1
        }
        elseif ($_ -match "^\-[^\-]") {
            $changes[1] += 1
        }
    }
    return $changes
}

function ParseStatusLine([string]$line) {
    $res = $line -match "^([\w\-\.]+)\s+(edit|! rename|! add|add)\s+(.*)$"
    $prefix = ""
    $action = $matches[2]
    if ($action.StartsWith("! ")) {
        $prefix = "!"
        $action = $action.Substring(2)            
    }
    return @($prefix, $action, $matches[3])
}

##############################################################################
# Colorizers #################################################################
##############################################################################
function Colorize-Diff {
    <#
    .Synopsis
        Redirects a Universal DIFF encoded text from the pipeline to the host using colors to highlight the differences.
    .Description
        Helper function to highlight the differences in a Universal DIFF text using color coding.
    .Parameter InputObject
        The text to display as Universal DIFF.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PSObject]$InputObject
    )
    Process {
        $line = $InputObject | Out-String
        if ($line -match "^Index:") {
            PrintCyan $line
        }
        elseif ($line -match "^==========") {
        }
        elseif ($line -match "^(\+|\-|\=){3}") {
            PrintCyan $line
        }
        elseif ($line -match "^@{2}") {
            PrintGray $line
        }
        elseif ($line -match "^\+") {
            PrintGreen $line
        }
        elseif ($line -match "^\-") {
            PrintRed $line
        } 
        else {
            Print $line 
        }
    }
}

function Colorize-Status {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSObject]$InputObject
    )
    Process {
        $line = $InputObject | Out-String
        if ($line -match "^(File name|\-\-\-\-\-\-|\$/|\d+ change)") {
        }
        elseif ($line.trim() -eq "") {
        }
        else {
            $res = ParseStatusLine $line

            $prefix = $res[0]
            $action = $res[1]
            $fname = $res[2].trim()

            $col = "Red"
            if ($action -eq "edit") {
                $col = "Green"
            } elseif ($action -eq "add") {
                $col = "DarkMagenta"
            }
            $nSpaces = 10
            if ($prefix -eq "!") {
                PrintWhite "! "
                $nSpaces -= 2
            }                
            PrintCol ("{0,-$nSpaces}" -f $action) $col
            Print ("{0,-80}" -f $fname)

            $changes = CountChanges $fname ""
            $plus = " {0,4}" -f $changes[0]
            $minus = " {0,4}" -f -$changes[1]
            PrintCyan $plus
            PrintRed $minus
            Write-Host
        }
    }
}

##############################################################################

function Show-TfsDiff {
    #requires -version 2
    if ($args.length -eq 0) {
        [Array]$args = "."
    }
    tf diff $args /recursive /noprompt | Colorize-Diff
}

function Show-TfsStatus {
    #requires -version 2
    if ($args.length -eq 0) {
        [Array]$args = "."
    }
    tf status /recursive $args | Colorize-Status
}

##############################################################################
New-Alias -name mydf -value Show-TfsDiff
New-Alias -name myst -value Show-TfsStatus

Export-ModuleMember -Function Show-* -Alias mydf,myst
