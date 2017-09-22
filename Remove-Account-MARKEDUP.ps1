# AD Account Decommissioner

# Parameters
[cmdletbinding()]
param(
	[parameter(Mandatory=$true)][string]$TicketNumber,

	[parameter(
		Mandatory=$true, 
		ValueFromPipeline=$true
	)]
	$Identity = @()
)

# Includes
Add-Type -Assembly "System.IO.Compression.FileSystem";
#$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchangeserver/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session


# Get User(s)
[array]$colUsers = Get-ADUser -Identity $Identity -pr * ;

# Go through all selected users
ForEach($User in $colUsers)
{
	[string]$Name = $User.Name;

	write-host "* Decommissioning Account: $Name";

	# Add Ticket to Description
	write-host "	* Adding Ticket Number $TicketNumber ... " -nonewline;
	Try
	{
		[string]$Desc = $User.Description + " - Decommission Ticket: $TicketNumber";
		Set-ADUser -Identity $User -Description $Desc;
		write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "[ ERROR ]" -ForegroundColor 12;
	}

	# Clear Manager Field
	write-host "	* Clearing Manager property ... " -nonewline;
	Try
	{
		Set-ADUser -Identity $User -Manager $null;
		write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "[ ERROR ]" -ForegroundColor 12;
	}

	# Remove Group Memberships
	write-host "	* Clearing MemberOf property ..." -nonewline;
	Try
	{
		# Set Primary Group back to Domain Users
		Set-ADUser $User -Replace @{PrimaryGroupID="513"};

		[array]$colGroups = Get-ADPrincipalGroupMembership -Identity $User | ? {$_.name -ne "Domain Users"} | % {Remove-ADGroupMember -Identity $_ -Members $User -Confirm:$false};
		write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "[ ERROR ]" -ForegroundColor 12;
	}

	# Disable Object
	write-host "	* Disabling $Name ..." -nonewline;
	#Try
	#{
		Disable-ADAccount $User -Confirm:$false;
		write-host "[ OK ]" -ForegroundColor 10;
	#}
	#Catch
	#{
		#write-host "[ ERROR ]" -ForegroundColor 12;
	#}
    # Move Disabled Object to Disabled OU
	[string]$Month = Get-Date | % {$_.Month};
    if($Month.length -eq 1) {$month = "0$month"}
	[string]$City = $User.City;

	# Get if Consultant
	If($User.DistinguishedName -like "*OU=Consultants*"){ $City = "Consultants"; }

	[string]$OUDisabled = "OU=$Month,OU=$City,OU=DisabledAndExpiredAccounts,OU=OFFICE,DC=office,DC=company,DC=com";
	write-host "	* Moving $Name to $OUDisabled ..." -nonewline;
	Try
	{
		Move-ADObject $User -TargetPath $OUDisabled -Confirm:$false;
		write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "[ ERROR ]" -ForegroundColor 12;
	}

    # Archive Home Folder
	$SourcePath = "\\namespace\public\users\$Identity";
	$TargetPath = "\\fileserver\HomeDriveBackup\$($Identity).zip";
	write-host "	* Archiving Home Folder: $SourcePath to $TargetPath ..." -nonewline;
	Try
	{
		[io.compression.zipfile]::CreateFromDirectory($SourcePath,$TargetPath);
		write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "[ ERROR ]" -ForegroundColor 12;
	}

	# Hide E-Mail address from Exchange address list
	write-host "	* Hiding E-Mail address of $Name from Exchange Address List..." -nonewline;
	Try
	{
		#$Credential = Get-Credential;
		#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://cyo-ex-01/powershell -Authentication Kerberos -Credential $Credential;
		Set-MailBox -Identity $Identity -HiddenFromAddressListsEnabled $true
        write-host "[ OK ]" -ForegroundColor 10;
	}
	Catch
	{
		write-host "Error executing Exchange steps." -ForegroundColor 12;
	}
}