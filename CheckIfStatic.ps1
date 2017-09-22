
$servers = Get-ADComputer -Filter * -SearchBase “OU=WindowsServer,OU=OFFICE,DC=office,DC=company,DC=dom” | Where{$_.Name -like "sto*"} | Select-Object -ExpandProperty name


#$servers = Get-Content "C:\Scripts\computers.txt" 

#$servers | % {
#    Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $_ | Where{$_.DHCPEnabled -eq $false -and $_.DNSHostName -ne $null} | Select-Object DNSHostName, DHCPEnabled, IPAddress | % {
#        $_ | format-list *
#    }
# }
# break

foreach($server in $servers)

    {
        Try 
            {
                $nics = Get-WMIObject -class Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Stop | Where{$_.DHCPEnabled -eq $false -and $_.DNSHostName -ne $null} | Select-Object DNSHostName, DHCPEnabled, IPAddress

                foreach($nic in $nics)
                    {
                            Write-Host "`tComputers with Static: " $nic.DNSHostName, $nic.IPAddress
                    }           
            }

        Catch 
            {
                Write-Warning "`tRPC Server unavailable, probably server 2008 $server"                
            }
  
  
        
    }