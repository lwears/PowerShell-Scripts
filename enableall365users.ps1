# Import MS Online add in
Import-Module MSOnline

#Login to 
$cred = Get-Credential
Connect-MsolService -Credential $cred

$unlicenseduserList = Get-MsolUser -All | 
                                where {$_.IsLicensed -eq $true `
                                -and $_.UserPrincipalName -notlike "svc*" }
                                #-and ($_.City -eq "Dallas" -or $_.City -eq "Seattle")

$myO365Sku2 = New-MsolLicenseOptions `
                                -AccountSkuId {AccountSKUID} `
                                -DisabledPlans RMS_S_ENTERPRISE, SHAREPOINTWAC, SWAY, YAMMER_ENTERPRISE, EXCHANGE_S_ENTERPRISE
				# Remove unwanted services

foreach ($eachuser in $unlicenseduserList){
                                Set-MsolUser `
                                  -UserPrincipalName $eachuser.UserPrincipalName `
                                  -UsageLocation "SE"
                                Set-MsolUserLicense `
                                  -UserPrincipalName $eachuser.UserPrincipalName `
                                  -AddLicenses AccountSKUID
                                Set-MsolUserLicense `
                                  -UserPrincipalName $eachuser.UserPrincipalName `
                                  -LicenseOptions $myO365Sku2
                              }