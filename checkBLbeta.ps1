# Get Computer Object
$computers = Get-ADComputer -Filter * -SearchBase "OU=Stockholm,OU=Laptops,OU=Windows 10,OU=Computers,OU=OFFICE,DC=office,DC=company,DC=dom"
$index = @()

foreach ($Computer in $computers)

        {
            $row = New-Object psobject
            $row | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $computer.DNSHostName
            

                if (Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $computer.DistinguishedName -Properties 'msFVE-RecoveryPassword')
                    {
                        #Write-Host $Computer.DNSHostName -ForegroundColor red
                        $row | Add-Member -MemberType NoteProperty -Name "HaveKey?" -Value "True"                    }
                    }
                else
                    {
                        $row | Add-Member -MemberType NoteProperty -Name "HaveKey?" -Value "False"
                    }
      
               $index += $row
        
               

   $index | Format-Table -AutoSize


# Get all BitLocker Recovery Keys for that Computer. Note the 'SearchBase' parameter
#$BitLockerObjects = Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $computer.DistinguishedName -Properties 'msFVE-RecoveryPassword'

