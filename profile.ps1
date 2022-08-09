# Use utf8 (without BOM) for Out-File
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# ==========================================================
# Profile settings
# ==========================================================

$ProfilePath = $MyInvocation.MyCommand.Path
$ProfileDir = Split-Path $ProfilePath

function Edit-Profile {
    Write-Verbose "Opening $ProfileDir with code"
    code $ProfileDir
}

function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if (Test-Path $_) {
            Write-Verbose "Running $_"
            . $_
        }
    }    
}

# ==========================================================
# ==========================================================

function Add-Path($newPath) {
    $env:PATH = $newPath + ';' + $env:PATH
}

# User binaries
@(
    "$env:USERPROFILE\bin"
    "$env:USERPROFILE\.local\bin"
    "$ProfileDir\bin"
) | ForEach-Object {
    Add-Path $_
}

function Test-Command {
    [CmdletBinding()]
    param($Name)

    $oldPreference = $ErrorActionPreference
    Write-Verbose "Previous ErrorActionPreference: $ErrorActionPreference"
    $ErrorActionPreference = "Stop"
    Write-Verbose "Set ErrorActionPreference to 'Stop'"

    try {
        $command = Get-Command $Name
        Write-Verbose "Command Exists $command"
        return $true
    }
    catch {
        Write-Verbose "Command $Name does not exist" 
        return $false
    }
    finally {
        $ErrorActionPreference = $oldPreference
        Write-Verbose "Restore ErrorActionPreference: $ErrorActionPreference"
    }
}
Set-Alias test Test-Command

# editor
function Get-DefaultEditor ($path) {
    @(
        "code"
        "nvim"
        "vim"
    ) | ForEach-Object {
        if (Test-Command $_) {
            return $_
        }
    }
    return "notepad"
}
$DefaultEditor = "code" # $(Get-DefaultEditor)
function Open-PathWithEditor ($path) {
    Invoke-Expression "$DefaultEditor $path"
}

# ==========================================================
# Visual
# ==========================================================

# Readline
# --------
# Import-Module PSReadline
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
$env:VISUAL = $DefaultEditor

try {
    Import-Module PSFzf -ErrorAction Stop
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
}
catch {
    Write-Verbose "Skip loading PSFzf"
}

# TODO: too slow to import...
# try {
#     Import-Module posh-git -ErrorAction Stop
# }
# catch {
#     Write-Verbose "Skip loading posh-git"
# }

# Starship shell
# --------------
if (Test-Command starship) {
    Invoke-Expression (&starship init powershell)
}

function Edit-StartshipConfig {
    $ConfigPath = $(Join-Path $HOME ".config/starship.toml")
    Open-PathWithEditor $ConfigPath
}

# oh-my-posh shell
# ----------------
# https://githubmemory.com/repo/JanDeDobbeleer/oh-my-posh2/issues/251
# 
# Install-Module posh-git -Scope AllUsers -Force
# Install-Module oh-my-posh -Scope AllUsers -Force
# Set-Theme Agnoster

# ==========================================================
# misc
# ==========================================================

# Util sciprt
Get-ChildItem $ProfileDir\utils\*.ps1 | ForEach-Object { . $_.FullName }

# Local profile
$LocalProfilePath = "$HOME\profile.local.ps1"
if (Test-Path $LocalProfilePath) { . $LocalProfilePath }

# cheat
# - https://github.com/OpenJNY/cheat
$env:CHEAT_CONFIG_PATH = "~/cheat/conf.yml"
if (Test-Command curl.exe) {
    function Get-CheatSheet([string]$name) {
        Write-Output (curl.exe -s "cheat.sh/$name")
    }
    Set-Alias cht Get-CheatSheet
}
