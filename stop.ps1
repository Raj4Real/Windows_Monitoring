	
	
	## Remove Scheduled Task from Task Scheduler
	
try
{
	Unregister-ScheduledTask -TaskName "EMS Win Monitoring"
	

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$uri = "https://iems-inter-orion-4.iems.orion.altus.bblabs:8443/ORIONINTER4/svcpost/deregister"
	$de_register = Get-Content "$PSScriptRoot\de_register.json"
		
	Invoke-RestMethod -uri $uri -Method Post -Body ($de_register) -ContentType "application/json"
}
catch
{
 echo "Monitoring was not running"
}	