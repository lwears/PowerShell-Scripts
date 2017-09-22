# Fetch DNS settings from Domain Controllers
#
# Liam Wears (2017) 
# liamwears@fastmail.com
#
# inspired from https://gallery.technet.microsoft.com/scriptcenter/Change-DNS-ip-addressess-912954b2
#

# MAIN

# if you want to pull in computers from an OU
$servers = Get-ADComputer -Filter * -SearchBase “OU=Domain Controllers,DC=office,DC=company,DC=dom” | Select-Object -ExpandProperty name

#put server computer names in text file and pull in from here
#$servers = Get-Content "C:\Scripts\computers.txt"
foreach($server in $servers)

{
    Write-Host "`tConnecting to $server..." -ForegroundColor DarkYellow

    # to get the computers IP settings assigned to the variable
    $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Inquire | Where{$_.IPEnabled -eq "TRUE"}

    $newDNS = "10.99.5.11","10.99.5.11","127.0.0.1"

    foreach($nic in $nics)

    {

        Write-Host "`tExisting DNS Servers " $nic.DNSServerSearchOrder

        # If DNS contains old DNS server
        if ($nic.DNSServerSearchOrder -contains "10.99.5.10")

        # Change DNS settings as per $newdns variable
        {     $x = $nic.SetDNSServerSearchOrder($newDNS)

                if($x.ReturnValue -eq 0)

                {
                    Write-Host "`tSuccessfully Changed DNS Servers on " $server -ForegroundColor Green
                }
                else
                {
                    Write-Host "`tFailed to Change DNS Servers on " $server -ForegroundColor Red
                }
        
        }        
        else 
        {
            Write-Host "`tDNS does not need changing on $server" -ForegroundColor Yellow
        }
            # write out the DNS settings as per script exit
            $nics = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $server -ErrorAction Inquire | Where{$_.IPEnabled -eq "TRUE"}
            Write-Host "`tDNS Servers " $nics.DNSServerSearchOrder "`n" -ForegroundColor 10

    }

}