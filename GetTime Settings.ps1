# Fetch DNS settings from Domain Controllers
#
# Liam Wears (2017) 
# liam.wearsr@netent.com
#

$servers = Get-ADComputer -Filter * -SearchBase “OU=Domain Controllers,DC=office,DC=company,DC=dom” | `
    Select-Object -ExpandProperty name

Write-Host "`t`tTime Settings for domain controllers`n"
Write-host "ServerName `t`t`t Time Source `t`t`t`t Reg Setting"
Write-Host "-------------------------------------------------------------"


$output = foreach ($server in $servers){

    # get reg settings for w32tm
    $timetype = Invoke-Command -ComputerName $server {Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" | select Type}
    #get w32tm time source
    $timesource = Invoke-Command -ComputerName $server {w32tm /query /source}

    #clean output
    Write-Host $server -NoNewline "`t`t`t"
    Write-Host $timesource -NoNewline "`t`t`t"
    Write-Host $timetype.Type
 
}

$output | Out-File C:\Users\admliawea\Documents\servertimesettings.txt
