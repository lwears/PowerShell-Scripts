Get-ADUser -SearchBase "OU=Accounts,OU=Users,DC=office,DC=company,DC=dom" -Filter * -Properties Enabled, AccountExpirationDate, LastLogonDate | ? { `
($_.Enabled -EQ $False) -OR `
($_.AccountExpirationDate -NE $NULL -AND $_.AccountExpirationDate -LT (Get-Date)) -and `
($_.LastLogonDate -NE $NULL -AND $_.LastLogonDate -LT (Get-Date).AddDays(-30)) } | select name
