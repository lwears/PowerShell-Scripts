$OldComputers = Get-ADComputer -Filter * -SearchBase "CN=Computers,DC=office,DC=company,DC=dom" -Properties PasswordLastSet | Where-Object {$_.PasswordLastSet -LT $(Get-Date).adddays(-120)}

foreach ($oldcomputer in $OldComputers) 
{
    if(!(Test-Connection $OldComputer.Name -count 1 -ErrorAction:SilentlyContinue))
    {
        Set-ADComputer -Identity $oldcomputer -Enabled $false
        Write-Host $oldcomputer.Name "being disabled..." -ForegroundColor Yellow
        Move-ADObject -Identity $oldcomputer -TargetPath "OU=2017-08,OU=Decommissioned,OU=Computers,OU=OFFICE,DC=office,DC=company,DC=dom"
        Write-Host $oldcomputer.Name "Moving Ou" -ForegroundColor Yellow
        Write-Host     
    }
    else
    {
        Write-host "$($OldComputer.name) Alive" -ForegroundColor Green
    }

}
    
     