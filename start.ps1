
## Initializing Variables
$config_path = "$PSScriptRoot\alarm_config.json"
$config = get-content -path $config_path | convertFrom-Json
$minutes = $config.Interval.Minutes
$script_path = "-File $PSScriptRoot\script.ps1"
$alarm_model = get-content "$PSScriptRoot\alarm_model.json" | ConvertFrom-Json

## Creating task to run script in Task Scheduler
$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument $script_path
$trigger =  New-ScheduledTaskTrigger `
 -Once `
 -At (Get-Date) `
 -RepetitionInterval (New-TimeSpan -Minutes $minutes)
 $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
 
  Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "EMS Win Monitoring" -Description "Ems windows monitoring" -Principal $principal -force
 
 $host_type = $config.Define.type
 $time_stamp = (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds
 $time_stamp = [Math]::Round($time_stamp,0)
 
 # Get hostname and IP
	if($config.HostName)
	{	
		$computer_name = $config.HostName
	} else {	
		$computer_name = hostname
	} #config.hosts
	$computer_IP = (
		Get-NetIPConfiguration |
		Where-Object {
			$_.IPv4DefaultGateway -ne $null -and
			$_.NetAdapter.Status -ne "Disconnected"
		}
	).IPv4Address.IPAddress
 
 $alarm_model.jsonData.id.timestamp = $time_stamp
 $alarm_model.jsonData.id.regionId = $config.Define.regionId
 $alarm_model.jsonData.id.group = $config.Define.group
 $alarm_model.jsonData.id.type = $host_type
 $alarm_model.jsonData.id.serviceName = echo "$host_type-$computer_name"
 $alarm_model.jsonData.id.hostInfo.hostName = $computer_name
 $alarm_model.jsonData.id.hostInfo.hostIp = $computer_IP
 $alarm_model.jsonData.id.hostInfo.version = $config.Define.version
 $EMS_URI = $config.Define.EMS_URI
	
 $alarm_model | ConvertTo-Json -Depth 100 | Out-File "$PSScRIPTrOOT\temp_model.json"
 
 # sending Alarm Model to EMS
 [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
 $uri = "$EMS_URI/model"
 $alarm = Get-Content "$PSScriptRoot\temp_model.json"
		
 Invoke-RestMethod -uri $uri -Method Post -Body ($alarm) -ContentType "application/json"