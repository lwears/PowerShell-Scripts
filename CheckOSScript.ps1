﻿$ComputerList = Get-ADComputer -SearchBase "OU=Computers,DC=office,DC=company,DC=dom" -Filter 'enabled -eq $true'
$index = @()

foreach ($computer in $computerlist) {
    if((Test-Connection -Cn $computer.DNSHostname -BufferSize 16 -Count 1 -ea 0 -quiet))
    {
        $OS = Get-WmiObject -Computer $computer.DNSHostname -Class Win32_OperatingSystem
        if($OS.caption -like '*2008*'){
            #Write-host $computer.DNSHostname "`tServer 2008" -ForegroundColor Red
                $row = New-Object psobject
                $row | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $computer.DNSHostName
                $row | Add-Member -MemberType NoteProperty -Name "OS" -Value "2008"
                $index += $row
        }
        if($OS.caption -like '*2012*'){
             #Write-host $computer.DNSHostname "`tServer 2012" -ForegroundColor Green
                $row = New-Object psobject
                $row | Add-Member -MemberType NoteProperty -Name "Hostname" -Value $computer.DNSHostName
                $row | Add-Member -MemberType NoteProperty -Name "OS" -Value "2012" 
                $index += $row
        }
        
    }
}
    $index