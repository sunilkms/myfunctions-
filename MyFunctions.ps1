#Author: Sunil Chauhan
#EMAIL:sunilkms@gmail.com
# These are the functions i setup to make my daily work easy.

#Connect Exchange Online work in EXO Module-----
Function ConnectExchOnline 
{
	Try	{
		"Trying connecting to Exchange Online"
		Connect-EXOPSSession -Credential $Cred -ea Stop 
		} 
	catch {
		"Failed to connect try connectin gusing MFA if you are not of company network" 
		}
}

#Connect Exchange online protection - Work with EXO MFA module
Function ConnectEXOP 
{
	Try	{
		"Trying connecting to Exchange Online Protection"
		Connect-IPPSSession -Credential $Cred -ea Stop 
		} 
	catch {
		"Failed to connect try connectin gusing MFA if you are not of company network" 
	      }
}

#Connect Priviledged Identity Management -
#if not installed alredy, install instruction "https://www.sunilchauhan.info/2018/11/azure-ad-privileged-identity-management.html"
Function ConnectPIM 
{
	Try	{
		"Trying connecting to Exchange Online Protection"
		Connect-PimService -Credential $Cred -ea Stop 
		} 
	catch {
		"Failed to connect try connectin gusing MFA if you are not of company network" 
	      }
}

#Get your current active roles
Function GetRolesStatus {Get-PrivilegedRoleAssignment | ft }

#Enable basic auth in registry if disabled, powershell should be started using administrator
Function EnableBASICAuth {
	try {
 		$regpath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client"
		if (!(Get-ItemProperty $regpath).Allowbasic) {Set-ItemProperty -Path $regpath -Name AllowBasic -Value 1 -ea Stop}
		Get-ItemProperty $regpath
	    }
     catch { Write-host "Failed to update the basic Auth, start powershell with admin rights" -f yellow} 
}

#Get Msol user errors 
Function GetMsol-UserError 
{
	Param ($user)
	$e = Get-MsolUser -UserPrincipalName $user
	$e.Errors | % {$_.ErrorDetail.ObjectErrors.ErrorRecord.ErrorDescription}
}

#Get Assigned Licenses to a user (Should be connected to MSOL)
Function GetMsol-AssignedUserLicenses {
Param ($user)
            $e = Get-MsolUser -UserPrincipalName $user
            $e.Licenses | % {
""
$l="------------------------------------------------------"
$l
$_.AccountSkuId
$l
""
           $_.ServiceStatus
                          }
}

#Connect to onpremise Exchange Server
Function ConnectOnpremiseExchange {
$UserAccount = "" #update your userid and password.
$Password = $cred.GetNetworkCredential().password # update your password
$cred = new-object –TypeName System.Management.Automation.PSCredential –ArgumentList $UserAccount, (ConvertTo-SecureString $Password –AsPlainText –Force)
#We can use Kerberos authentication instead of basic if we does not have certificate installed from trusted authority, limitation are that you can only connect to exchange #powershell from the domain joined system.
$s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchange1.sunil.com/powershell/?SerializationLevel=Full `
-Credential $cred -Authentication Kerberos -AllowRedirection
Import-PSSession $s -AllowClobber }
