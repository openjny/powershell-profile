# powershell-profile

## Installation

### Using git

```
cd $HOME\Documents
git clone https://github.com/OpenJNY/powershell-profile.git PowerShell
```

### Manual setup

1. Download the zip file from [Code] > [Download ZIP]
2. Extract files
3. Create a directory with `$HOME\Documents\PowerShell`
4. Locate all files under the direcotry. 

You should get true when executing the follwoing command:  

```ps1
PS> Test-Path $HOME\Documents\PowerShell\profile.ps1
True
```