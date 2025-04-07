$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path $script_path

# Require scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Please install Scoop first."
    exit 1
}

# Install dependencies
scoop install starship fzf neovim zoxide
Install-Module PSFzf -Scope CurrentUser
# Install-Module posh-git -Scope CurrentUser

# Create symlink to starship.toml
if (!(Test-Path $HOME\.config\starship.toml)) {
    Write-Host "Creating symlink for starship.toml ($HOME\.config\starship.toml)"
    Start-Process "cmd.exe" -ArgumentList "/c mklink $HOME\.config\starship.toml $script_dir\starship.toml" -Verb runas
}

# touch a Tlcalfilprofile  e if it doesn't exist
if (!(Test-Path $HOME\profile.local.ps1)) {
    Write-Host "Creating profile.local.ps1 ($HOME\profile.local.ps1)"
    New-Item -Path $HOME\profile.local.ps1 -ItemType File
}