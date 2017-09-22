#This script automatically licenses Office 365 unlicensed users and Provisions OneDrive/Personal Site for the new users
 
Import-Module MSOnline
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
 
 
#Fix Powershell ISE and powershell to be able to run .net 2.0 and .net 4.0 code and clr version for powershell     
#    or     http://stackoverflow.com/questions/2094694/how-can-i-run-powershell-with-the-net-4-runtime
#Azure AD Module (x64): http://go.microsoft.com/fwlink/p/?linkid=236297  or https://msdn.microsoft.com/en-us/library/jj151815.aspx
#.NET 4.5.1 or 4.5.2
#SharePoint Online SDK? install https://www.microsoft.com/en-us/download/details.aspx?id=42038
#SharePoint Online Management Shell https://www.microsoft.com/en-us/download/details.aspx?id=35588
#Microsoft Online Services Sign-In Assistant https://www.microsoft.com/en-us/download/details.aspx?id=28177
#Powershell 3.0 https://www.microsoft.com/en-us/download/details.aspx?id=34595
#Make sure one drive for admin account already has onedrive provisioned and licensed for onedrive
#Tile -> Admin -> Admin -> SharePoint -> Settings ->
#SharePoint Online Management Shell https://technet.microsoft.com/en-us/library/fp161372.aspx
#Turn Scripting capabilities on in Office365  https://support.office.com/en-us/article/Turn-scripting-capabilities-on-or-off-1f2c515f-5d7e-448a-9fd7-835da935584f
 
#License Information: https://technet.microsoft.com/en-us/library/dn771773.aspx
 
#Office 365 Licensing list 
  
 
#Must be SharePoint Administrator URL
$webUrl = "https://netent-admin.sharepoint.com";
 
#update and store password as necessary
$logfile = 'c:\ScheduledTasks\StudentLicensesAdded.txt';
$passwordfile = 'C:\ScheduledTasks\passwordfile.txt';
 
$username = "auto.licenser@netent.com";
 
$passwd = "Netent2016"

$secpasswd = ConvertTo-SecureString $passwd -AsPlainText -Force
 
$mycreds = New-Object System.Management.Automation.PSCredential($username, $secpasswd);
 
#Connect to msolservice
connect-msolservice -credential $mycreds;
 
 
 
#test get user
#Get-MsolUser -UserPrincipalName johns@contoso.com
 
#testing
 
#Find and get all unlicensed Student Users and filter as desired
$unlicenseduserList = Get-MsolUser -All -Synchronized | where {$_.IsLicensed -eq $false -and $_.UserPrincipalName -notlike "*svc*" -and $_.UserPrincipalName -notlike "user*" -and $_.Title -notlike "" -and $_.Office -notlike "remoteoffice" -and $_.UserPrincipalName -notlike "*test*"}
 
#License Options to disable    
#View your licenses
#Get-MsolAccountSku
#License Information:   https://technet.microsoft.com/en-us/library/dn771773.aspx
$myO365Sku2 = New-MsolLicenseOptions -AccountSkuId {AccountSKUID} -DisabledPlans RMS_S_ENTERPRISE, SHAREPOINTWAC, SWAY, YAMMER_ENTERPRISE, EXCHANGE_S_ENTERPRISE, FLOW_O365_P2, POWERAPPS_DYN_APPS, FLOW_DYN_APPS, POWERAPPS_O365_P2, TEAMS1
 
#Setup/license new users in Office 365
if ($unlicenseduserList)
{
    foreach ($eachuser in $unlicenseduserList)
    {
        Write-Host "Assigning License to user:";
        Write-Host $($eachuser.UserPrincipalName);
         
        #Change your location as necessary
        Set-MsolUser -UserPrincipalName $eachuser.UserPrincipalName -UsageLocation "SE";
         
        #This activates the licenses and all plans are active
        Set-MsolUserLicense -UserPrincipalName $eachuser.UserPrincipalName -AddLicenses AccountSKUID;
        #this disables the plans specified in the license options
        Set-MsolUserLicense -UserPrincipalName $eachuser.UserPrincipalName -LicenseOptions $myO365Sku2
        $nstudent = $($eachuser.UserPrincipalName);
        Add-Content $logfile $nstudent;
    }
}
else
{
    Write-Host "No Users to License";
}
Write-Host "Licensing Finished";
 
 
Write-Host "OneDrive Provisioning";
 
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $secpasswd
 
Connect-SPOService -Url $webUrl -Credential $cred
 
Write-Host "Connected to site: $webUrl" -ForegroundColor Green;
 
#Test view all sites, connection working?
#Get-SPOSite
 
if ($unlicenseduserList)
{
    $usercount = 1;
    $usersToProvision = @();
    foreach ($eachuser in $unlicenseduserList)
    {
     
        #Break up the work into batches of 10 you can try up to 200
        if ($usercount -gt 10)
        {
            Write-Host "Provisioning OneDrive for users:";
            $usersToProvision;
            #CreatePersonalSiteEnqueueBulk does not work! use the code below instead
            Request-SPOPersonalSite -UserEmails $usersToProvision;
            $usersToProvision = @();
            $usercount = 1;
        }
         
        #Add to queue 
         
        $onedriveuser = [string]$($eachuser.UserPrincipalName);
        $usersToProvision += $onedriveuser;
        #Write-Host $onedriveuser;
        $usercount++;
    }
     
    #Run the last batch 
    if ($usercount -gt 1)
    {
        Write-Host "Provisioning OneDrive for users:";
        $usersToProvision;
        #CreatePersonalSiteEnqueueBulk does not work! use the code below instead
        Request-SPOPersonalSite -UserEmails $usersToProvision;
        $usersToProvision = @();
        $usercount = 1;
    }
}
else 
{
    Write-Host "No Users to Provision";
}
 
 
 
 
Write-Host "One Drive Provisioning Completed" ;
Disconnect-SPOService;
 
#to Test Provisioning succeeded
#Wait a few hours before testing
#Login to Office 365 using an account then hit the url below replacing username as desired
#https://[ORGANIZATION SITE]-my.sharepoint.com/personal/[UserPrincipalName replace "@" with "_"    and "." with "_"]
