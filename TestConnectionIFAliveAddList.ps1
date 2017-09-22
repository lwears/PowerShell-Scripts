$ComputerList = Get-ADComputer -SearchBase "OU=WSUS Managed,OU=WindowsServer,OU=OFFICE,DC=office,DC=necorp,DC=dom" -Filter *

foreach ($Computer in $ComputerList)

        {

                if (Test-Connection -ComputerName $computer.DNSHostName -Count 1 -quiet) {
                Write-Host $computer.DNSHostName "alive"

                }

                else {
                        
                        Write-Host $Computer.DNSHostName "host dead"
                 }

        }

