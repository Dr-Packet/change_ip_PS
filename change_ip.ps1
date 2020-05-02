

# Retrieve the network adapter that you want to configure
$active_adapters = Get-NetIPConfiguration | ? {$_.NetAdapter.Status -ne "Disconnected"}
$dhcp_holder = Get-NetIPAddress | ? {$_.AddressFamily -eq "IPv4"}

ForEach ($i in $active_adapters) {


   ForEach ( $j in $dhcp_holder){
    
    if ($j.InterfaceAlias -eq $i.InterfaceAlias){

        $current_ip_address = $j.IPAddress, $j.PrefixLength -join "/"
        
        Write-Output $j.InterfaceAlias
        Write-Output $j.PrefixOrigin 
        Write-Output $current_ip_address
        Write-Output $i.IPv4DefaultGateway.NextHop # This one uses $i
        Write-Output $i.DNSServer.ServerAddresses   # This one uses $i
        Write-Output "`r"

        
        }
   
   }






}

#Write-Output $active_adapters 




<#
# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
    -AddressFamily $IPType `
    -IPAddress $IP `
    -PrefixLength $MaskBits `
    -DefaultGateway $Gateway

# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

#>




$InterfaceAlias = Read-Host -Prompt 'Please enter InterfaceAlias you want to adjust '
$dhcp_choice = Read-Host -Prompt 'DHCP y/n? '
$ip_type = "IPv4" # Maybe IPv6 will be used some day

If ($dhcp_choice -eq 'y'){

# Return network interface to a variable for future use
$interface = Get-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4

# Remove the static default gateway
$interface | Remove-NetRoute -AddressFamily $ip_type -Confirm:$false

# Set interface to "Obtain an IP address automatically"
$interface | Set-NetIPInterface -Dhcp Enabled
 
# Set interface to "Obtain DNS server address automatically"
$interface | Set-DnsClientServerAddress -ResetServerAddresses

Write-Output "Misson Complete Sir!"
break
} ElseIf ($dhcp_choice -eq 'n') {

$IP = Read-Host -Prompt 'Please enter the IP Address (192.168.x.x): '
$MaskBits = Read-Host -Prompt 'Please enter the Mask Bits (CIDR: 24) :  ' # Must be in CIDR
$Gateway = Read-Host -Prompt 'Please enter the Default Gateway: '
$dns_servers = Read-Host -Prompt 'Please enter the DNS (x.x.x.x,y.y.y.y,z.z.z.z):  '

New-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -IPAddress $IP -PrefixLength $MaskBits -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses dns_servers

Write-Output "Misson Complete Sir!"


} Else {
Write-Output "Mission failed :("
}

