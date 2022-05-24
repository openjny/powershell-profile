
function Select-MyAzSubscription {
    if ((test fzf) && (test jq)) {
        Get-AzSubscription | ConvertTo-Json | jq '.[] | {name: .Name, id: .Id}' -c | fzf | jq -r '.id' | % { Select-AzSubscription $_ }
    }
    else {
        Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription
    }
}
function select_subscription {
    if ((test az) && (test fzf) && (test jq)) {
        az account list | jq '.[] | {name: .name, id: .id}' -c | fzf | jq -r '.id' | % { az account set -s $_ }
    } else {
        Get-AzSubscription | Out-GridView -PassThru | Select-AzSubscription
    }
}

function start_appgw {
    Get-AzApplicationGateway | Select-Object Name, ResourceGroupName, OperationalState | Out-GridView -PassThru | ForEach-Object {
        Get-AzApplicationGateway -Name $_.Name -ResourceGroupName $_.ResourceGroupName | Start-AzApplicationGateway
    }
}

Set-Alias azsub Select-MyAzSubscription
Set-Alias azlogin Login-AzAccount
Set-Alias azexit Logout-AzAccount

function Select-AzPSObject ($PSObject) {
    if ((test fzf) && (test jq)) {
        return $PSObject | ConvertTo-Json | jq '.[] | {Name: .Name, ResourceGroupname: .ResourceGroupName}' -c | fzf | ConvertFrom-Json
    }
    else {
        return $PSObject | Out-GridView -PassThru
    }
}