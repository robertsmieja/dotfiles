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
$modules = (
    "FastPing",
    "posh-git",
    "oh-my-posh",
    "Terminal-Icons"
)
$modules | ForEach-Object {
    if (Get-Module -ListAvailable -Name $_) {
        Import-Module $_
    }
}
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

if (Test-Path "%USERPROFILE%\.krew\bin") {
    $Env:PATH = "%USERPROFILE%\.krew\bin;" + $Env:PATH
}

# k3d autocompletion
if (Get-Command k3d -ErrorAction SilentlyContinue) {
    $completions = $(k3d completion powershell)
    Invoke-Expression ($completions -join "`n")
}
