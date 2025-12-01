# powershell-profile

## Installation

```powershell
# install scoop first

cd $HOME\Documents
git clone https://github.com/OpenJNY/powershell-profile.git PowerShell

# using gh
gh repo clone openjny/powershell-profile PowerShell

.\PowerShell\setup.ps1
```

After the setup, you should get true when executing the following:

```powershell
Test-Path $HOME\Documents\PowerShell\profile.ps1
# True
```
