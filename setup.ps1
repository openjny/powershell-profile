$script_path = $MyInvocation.MyCommand.Path
$script_dir = Split-Path $script_path

scoop install starship
scoop install fzf
scoop isntall neovim
Install-Module PSFzf -Scope CurrentUser
# Install-Module posh-git -Scope CurrentUser

# symlink
New-Item -Path $HOME\.config\starship.toml -ItemType SymbolicLink -Value $(Join-Path $script_dir starship.toml)

# localfile
New-Item -Path $HOME\profile.local.ps1 -ItemType File