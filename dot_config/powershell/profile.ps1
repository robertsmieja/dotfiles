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
$ProfilePath = Split-Path -parent $profile

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

# Helper functions
# --------------------------------------------------------------------------
function Get-DuplicateFilesByHash {
    param(
        [string]$Path = "."
    )

    $hashes = @{}
    Get-ChildItem -Path $Path -Recurse |
    Where-Object { !$_.PSIsContainer } |
    ForEach-Object {
        # Calculate file hash and add to dictionary
        $hash = Get-FileHash $_.FullName
        if ($hashes.ContainsKey($hash.Hash)) {
            # Output duplicates
            $hashes[$hash.Hash] += @($_.FullName)
        }
        else {
            $hashes.Add($hash.Hash, @($_.FullName))
        }
    }

    foreach ($hash in $hashes.GetEnumerator()) {
        if ($hash.Value.Count -gt 1) {
            # Output duplicates
            Write-Output ($hash.Value -join "`n")
        }
    }
}
