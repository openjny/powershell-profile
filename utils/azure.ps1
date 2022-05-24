
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

function start_afw {
    # if ((test az) && (test fzf) && (test jq)) {
    #     $target_afw = $(az network firewall list | jq -c '.[] | select(.ipConfigurations == []) | {name, resourceGroup}' | fzf)
    #     $rg = $($target_afw | jq -r '.resourceGroup')
    # } else {
    $afw_metadata = Get-AzFirewall | Where-Object IpConfiguration -eq $Null | Select-Object Name, ResourceGroupName, Location | Out-GridView -PassThru
    $afw_metadata | ForEach-Object {
        # select PIPs
        $pip_metadata = Get-AzPublicIpAddress -ResourceGroupName $_.ResourceGroupName `
            | Where-Object IpConfiguration -eq $Null `
            | Where-Object Location -eq $_.Location `
            | Select-Object Name, ResourceGroupName, Location `
            | Out-GridView -PassThru
        # select VNets
        $vnet_metadata = Get-AzVirtualNetwork -ResourceGroupName $_.ResourceGroupName `
            | Where-Object Location -eq $_.Location `
            | Select-Object Name, ResourceGroupName, Location `
            | Out-GridView -PassThru
        
        $azfw = Get-AzFirewall -Name $_.Name -ResourceGroupName $_.ResourceGroupName
        $vnet = Get-AzVirtualNetwork -Name $vnet_metadata.Name -ResourceGroupName $vnet_metadata.ResourceGroupName
        $pip = $pip_metadata | ForEach-Object { Get-AzPublicIpAddress -Name $_.Name -ResourceGroupName $_.ResourceGroupName }
        $azfw.Allocate($vnet, $pip)
        Set-AzFirewall -AzureFirewall $azfw 
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