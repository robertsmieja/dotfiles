# -*-mode:powershell-*- vim:ft=powershell

# ~/.config/powershell/profile.ps1
# =============================================================================
# Executed when PowerShell starts.
#
# On Windows, this file will be copied over to these locations after
# running `chezmoi apply` by the script `../../run_powershell.bat.tmpl`:
#     - %USERPROFILE%\Documents\PowerShell
#     - %USERPROFILE%\Documents\WindowsPowerShell
#
# See https://docs.microsoft.com/en/powershell/module/microsoft.powershell.core/about/about_profiles

# Imports
# -----------------------------------------------------------------------------

# Setup a pretty development-oriented PowerShell prompt.
# $modules = (
#     "FastPing",
#     "posh-git",
#     "oh-my-posh",
#     "Terminal-Icons"
# )
# $modules | ForEach-Object {
#     if (Get-Module -ListAvailable -Name $_) {
#         Import-Module $_
#     }
# }
if (Get-Module -ListAvailable -Name "oh-my-posh") {
    Set-Theme Emodipt
}
# if (Get-Module -ListAvailable -Name "Terminal-Icons") {
#     Set-TerminalIconsColorTheme -Name "DevBlackOps"
# }


# Includes
# -----------------------------------------------------------------------------

# Determine user profile parent directory.
$ProfilePath = Split-Path -Parent $profile

# Load alias definitions from separate configuration file.
if (Test-Path $ProfilePath/aliases.ps1) {
    . $ProfilePath/aliases.ps1
}

# Load custom code from separate configuration file.
if (Test-Path $ProfilePath/extras.ps1) {
    . $ProfilePath/extras.ps1
}


# Varia
# -----------------------------------------------------------------------------

# Point ripgrep to its configuration file.
# See https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
$Env:RIPGREP_CONFIG_PATH = "$HOME/.ripgreprc"

if (Test-Path "${Env:USERPROFILE}\bin") {
    $Env:PATH += ";${Env:USERPROFILE}\bin"
}

if (Test-Path "${Env:USERPROFILE}\.krew\bin") {
    $Env:PATH += ";${Env:USERPROFILE}\.krew\bin"
}

# SOPS config
if (Test-Path "${Env:USERPROFILE}\sops\keys.txt") {
    $Env:SOPS_AGE_RECIPIENTS = "age1t4je0r0ttug44cel720gazwn64tzedrmzpypd77g00qu6dtnwsjszpe2v2"
    $Env:SOPS_AGE_KEY_FILE = "${Env:USERPROFILE}\sops\keys.txt"
}

# Set VSCode as default editor
if (Get-Command code -ErrorAction SilentlyContinue) {
    $Env:EDITOR = "code -w"
}

# k3d autocompletion
if (Get-Command k3d -ErrorAction SilentlyContinue) {
    $completions = $(k3d completion powershell)
    Invoke-Expression ($completions -join "`n")
}

# Python Poetry bin folder
if (Get-Command poetry -ErrorAction SilentlyContinue || Test-Path "${Env:APPDATA}\Python\Scripts") {
    $Env:PATH += ";${Env:APPDATA}\Python\Scripts"
}

# fnm - fast node manager
fnm env --use-on-cd | Out-String | Invoke-Expression

# Helper functions
# --------------------------------------------------------------------------
function Get-DuplicateFilesByHash {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [string]$Path = "."
    )

    Write-Verbose "Scanning files in $Path"

    $hashes = @{}
    $hashesToFileNames = @{}

    $files = Get-ChildItem -Path $Path -Recurse -File
    $totalFiles = $files.Count

    for ($fileCount = 0; $fileCount -lt $totalFiles; $fileCount++) {
        $file = $files[$fileCount]
        $percent = ($fileCount / $totalFiles * 100)
        Write-Progress -Activity "Scanning files" -Status "Processed $fileCount of $totalFiles files, $percent%" -PercentComplete $percent

        $fileHash = Get-FileHash $file.FullName -Algorithm MD5

        if ($fileHash) {
            # have we seen this hash before?
            if ($hashes.ContainsKey($fileHash.Hash)) {
                # retrieve list of files
                $fileList = $hashesToFileNames[$fileHash.Hash]
                if ($null -eq $fileList) {
                    $fileList = @()
                }

                # save to list of duplicate files
                $fileList += $fileHash.Path
                $hashesToFileNames[$fileHash.Hash] = $fileList
            }
            else {
                # we have not seen this hash before

                # record this file hash
                $hashes.Add($fileHash.Hash, $null)
            }
        }
    }

    $duplicates = @{}
    foreach ($entry in $hashesToFileNames.GetEnumerator()) {
        $key = $entry.Key
        $value = [string[]]$entry.Value

        if ($value.Count -gt 1) {
            $duplicates.Add($key, $value)
        }
    }


    Write-Progress -Completed -Activity "Found $($duplicates.Count) sets of duplicate files"

    return $duplicates      
}
