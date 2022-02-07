
##############################################################
##                                                          ## 
## Windows Monitoring Main Script - V 0.7                   ##
## Written by Raj Gadhiya (Service Specialist Student)      ##
## Connection is Power!                                     ##
##                                                          ##
##############################################################

$ErrorActionPreference = "Stop"

## Import Functions
. "$PSScriptRoot\cpu_check.ps1"
. "$PSScriptRoot\memory_check.ps1"
. "$PSScriptRoot\disk_check.ps1"
. "$PSScriptRoot\process_check.ps1"
. "$PSScriptRoot\service_check.ps1"
. "$PSScriptRoot\network_check.ps1"
. "$PSScriptRoot\increase_counter.ps1"

## Load config
$config_path = "$PSScriptRoot\alarm_config.json"
$template_path = "$PSScriptRoot\alarm_model.json"
$alert_path = "$PSScriptRoot\temp.json"
$stats_template_path = "$PSSCriptRoot\stats_template.json"
$stats_path = "$PSSCriptRoot\stats.json"
$ErrorLog = "$PSScriptRoot\ScriptErrors.txt"
$de_register_path = "$PSScriptRoot\de_register.json"
$id_counter_path = "$PSScriptRoot\id_counter.json"
$alarm_path = "$PSScriptRoot\alarm.json"
$alarm_template_path = "$PSScriptRoot\alarm_template.json"

$config = Get-Content -path $config_path -raw | ConvertFrom-Json
$alarm_model = Get-Content -path $template_path -raw | ConvertFrom-Json
$alarm_template = Get-Content $alarm_template_path | ConvertFrom-Json
$template = Get-Content -path $template_path -raw | ConvertFrom-Json
$alert = Get-Content -path $alert_path -raw | ConvertFrom-Json
$stats_template = Get-Content -path $stats_template_path -raw | ConvertFrom-Json
$stats = Get-Content -path $stats_template_path -raw | Convertfrom-Json
$id_counter = Get-Content -path $id_counter_path | ConvertFrom-Json
$de_register = Get-Content -path $de_register_path | ConvertFrom-Json
$flag = $config.Monitor
filter timestamp {"$(Get-Date -Format o): $_"}

## emptying templates to fill data from host
$template.jsonData.children = @()
$stats.jsonData.children.children | Foreach {$_.almStatus = "NULL"}


try
{
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

	### initializing templates from alarm_config.json
	$host_type = $config.Define.type
	$time_stamp = (New-TimeSpan -Start (Get-Date "01/01/1970") -End (Get-Date)).TotalSeconds
	$time_stamp = [Math]::Round($time_stamp,0)
	
	## Initializing alarms template (this one is to write alarm)
	$template.jsonData.id.timestamp = $time_stamp
	$template.jsonData.id.regionId = $config.Define.regionId
	$template.jsonData.id.group = $config.Define.group
	$template.jsonData.id.type = $host_type
	$template.jsonData.id.serviceName = echo "$host_type-$computer_name"
	$template.jsonData.id.hostInfo.hostName = $computer_name
	$template.jsonData.id.hostInfo.hostIp = $computer_IP
	$template.jsonData.id.hostInfo.version = $config.Define.version
	
	## Initializing alarm model (this one will be sent to EMS as Alarm Model once)
	#$alarm_model.jsonData.id.timestamp = $time_stamp
	#$alarm_model.jsonData.id.regionId = $config.Define.regionId
	#$alarm_model.jsonData.id.group = $config.Define.group
	#$alarm_model.jsonData.id.type = $host_type
	#$alarm_model.jsonData.id.serviceName = echo "$host_type-$computer_name"
	#$alarm_model.jsonData.id.hostInfo.hostName = $computer_name
	#$alarm_model.jsonData.id.hostInfo.hostIp = $computer_IP
	#$alarm_model.jsonData.id.hostInfo.version = $config.Define.version
	
	#$alarm_model | ConvertTo-Json -Depth 100 | Out-File "$PSScRIPTrOOT\temp_model.json"

	## Initializing Stat Packets (this one will be sent to EMS as Stats every minutes)
	$stats.jsonData.id.timestamp = $time_stamp
	$stats.jsonData.id.regionId = $config.Define.regionId
	$stats.jsonData.id.group = $config.Define.group
	$stats.jsonData.id.type = $host_type
	$stats.jsonData.id.serviceName = echo "$host_type-$computer_name"
	$stats.jsonData.id.hostInfo.hostName = $computer_name
	$stats.jsonData.id.hostInfo.hostIp = $computer_IP
	$stats.jsonData.children | where {$_.instance = echo "$host_type=$computer_name"}
	$stats.jsonData.children | where {$_.almStatus = ""}
	$stats.jsonData.id.hostInfo.version = $config.Define.version
	
	## Initializing De-Register Packet (this one will de-register host with EMS)
	$de_register.jsonData.id.timestamp = $time_stamp
	$de_register.jsonData.id.regionId = $config.Define.regionId
	$de_register.jsonData.id.group = $config.Define.group
	$de_register.jsonData.id.type = $host_type
	$de_register.jsonData.id.serviceName = echo "$host_type-$computer_name"
	$de_register.jsonData.id.hostInfo.hostName = $computer_name
	$de_register.jsonData.id.hostInfo.hostIp = $computer_IP
	$de_register.jsonData.id.hostInfo.version = $config.Define.version
	
	# Saving de-register packet
	$de_register | ConvertTo-Json -Depth 100 | Out-File $de_register_path
	
	# update stats for what is not being monitor
	if(!$flag.CPU)
	{
		# CPU is not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "CPU"} | Where {$_.usgState = "IDLE"}
	}
	if(!$flag.Memory)
	{
		# Memory is not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "Memory"} | Where {$_.usgState = "IDLE"}
	}
	if(!$flag.Storage)
	{
		# Storage is not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "Disk"} | Where {$_.usgState = "IDLE"}
	}
	if(!$flag.Processes)
	{
		# Processes are not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "Processes"} | Where {$_.usgState = "IDLE"}
	}
	if(!$flag.Services)
	{
		# Services are not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "Services"} | Where {$_.usgState = "IDLE"}
	}
	if(!$flag.Network)
	{
		# Network is not being monitored
		$stats.jsonData.children.children | Where {$_.instance -eq "Network"} | Where {$_.usgState = "IDLE"}
	}
	
	
	### CPU Monitoring ###
	
	if($flag.CPU) # if flag.cpu is true from alarm_config.json
	{
	## get cpu usage
	$temp = Get-WmiObject win32_processor -comp $computer_name | select NumberOfCores, LoadPercentage, DeviceID
	
	# saving cpu usage in variable
	New-Variable -Name "cpu_cores" -Value ($temp.NumberOfCores) -force
	New-Variable -Name "cpu_usage" -Value ($temp.LoadPercentage) -force
	New-Variable -Name "guid_cpu" -Value ($temp.DeviceID) -force
	
	# Rounding up to two decimals
	$temp = Get-Variable "cpu_usage" -ValueOnly
	$temp = [math]::Round($temp,2)

	# Calling cpu_check
	cpu_check -cpu_usage $temp -config_threshold $config -guid $guid_cpu
	
	} #flag.cpu ends
	
	
	### Memory/RAM Monitoring ###
	
	if($flag.Memory) # if flag.Memory is true from alarm_config.json
	{
	## get memory usage 
	$temp = Get-WmiObject Win32_OperatingSystem -comp $computer_name | select-object @{n='AvailableRAM';e={$_.FreePhysicalMemory/1MB}}, @{n='TotalRAM';e={$_.TotalVisibleMemorySize/1MB}}
	
	# saving memory usage to variables 
	New-Variable -Name "free_ram" -Value ($temp.AvailableRam) -force
	New-Variable -Name "total_ram" -Value ($total_ram = $temp.TotalRAM) -force
  
	# Converting memory usage into percentage
	if($total_ram -and ($total_ram -ne 0)) {
			$temp_usage = 100 - (($free_ram * 100)/$total_ram)
			New-Variable -Name "ram_usage" -Value $temp_usage -force
	} else {
			New-Variable -Name "ram_usage" -Value 0 -force
	} #total_ram
  
	# Rounding up to two decimals
	$temp = Get-Variable "ram_usage" -ValueOnly
	$temp = [math]::Round($temp,2)

	# Calling memory_check
	memory_check -ram_usage $temp -config_threshold $config 

	} #flag.Memory ends
	
	
	### Process Moitoring ###
	
	if($flag.Processes) # if flag.Processes is true from alarm_config.json
	{
	# calling Process_check 
	$process = $config.Processes.Process_List
	process_check -process $process -computer_name $computer_name
	} #flag.Processes ends
	
	
	### Service Monitoring ###
	
	if($flag.Services) # if flag.Services is true from alarm_config.json
	{
	# calling Service_check 
	$service = $config.Services.Service_List		
	service_check -service $service -computer_name $computer_name
	} #flag.Services ends
	
	
	### Disk/Storage Monitoring ###
	
	if($flag.Storage)
	{
	## Reading alarm_config.json 
	$disk_type = $config.Disk.DISKTYPE
	$filter_disks = $config.Disk.Filter_Disks
	$type_id = @() # Defining type_id array
	
	# Converting words to intiger which powershell uses to identify disks
	foreach($type in $disk_type)
	{
		if($type -eq "Unknown"){
			$type_id += 0
		}
		elseif($type -eq "No Root Directory"){
			$type_id += 1
		}
		elseif($type -eq "Removable Disk"){
			$type_id += 2
		}
		elseif($type -eq "Local Disk"){
			$type_id += 3
		}
		elseif($type -eq "Network Drive"){
			$type_id += 4
		}
		elseif($type -eq "Compact Disk"){
			$type_id += 5
		}
		elseif($type -eq "RAM Disk"){
			$type_id += 6
		}
	}#disk_type
	
	$exclude = @() # Defining exclude array
	if($filter_disks) # if filter disk is initialized from alarm_config.json
	{	
		foreach($f in $filter_disks)
		{
			$temp = $NULL
			# Get disk usage by drive letters from filter_disks
			$temp = Get-WmiObject Win32_Volume | 
						Where-Object {$_.DriveLetter -eq $f }
				
			New-Variable -Name free -Value ($temp.FreeSpace) -force
			New-Variable -Name total -Value ($temp.Size) -force
			New-Variable -Name device_id -Value ($temp.DeviceID) -force # saving this to identify the drive when alarm gets cleared
			New-Variable -Name drive_letter -Value ($temp.DriveLetter) -force
			New-Variable -Name disk_type -Value ($temp.DriveType) -force # adding this to exclude
			$device_id = $device_id -replace '\W' # removing spacial charectors from DeviceID

			# Converting into percentage
			if($total -and ($total -ne 0)) {
				$temp_usage = 100 - (($free * 100)/$total)
				New-Variable -Name disk_usage -Value $temp_usage -force
			} else {
				New-Variable -Name disk_usage -Value 0 -force
			}
			if($temp) # Calling disk_check only if filter_disks is set from config
			{
				# rounding up to two decimals
				$disk_usage = [math]::Round($disk_usage,2)
				# calling disk_check
				disk_check -disk_usage $disk_usage -config_threshold $config -disk_type $disk_type -drive_letter $drive_letter -guid $device_id	
			}
			$exclude += $disk_type 
		} #f
		
		# Removing disk types, which disks are already retrieved using filter_disk
		$type_id = $type_id | Where-Object {$exclude -notContains $_}
			
	} #Filter_Disks
	
	if($type_id) # if there are still disk types remain 
	{
		foreach($type in $type_id)
		{
			$temp_usage = $NULL
			$temp = $NULL
			
			# getting all disks by disk types (i.e. all local disks)
			$temp = Get-WmiObject Win32_Volume -comp $computer_name |
						Where-Object { $_.DriveType -eq $type } |
						Select-Object DeviceID, DriveType, DriveLetter, 
						@{n='FreeSpace';e={[int]($_.FreeSpace/1GB)}},
						@{n='Size';e={[int]($_.Capacity/1GB)}}
						
			foreach($sub_type in $temp) # seperating usage of each disk (i.e. checking usage of each disk from all Local Disks)
			{
				New-Variable -Name free -Value ($sub_type.FreeSpace) -force
				New-Variable -Name total -Value ($sub_type.Size) -force
				New-Variable -Name device_id -Value ($sub_type.DeviceID) -force
				New-Variable -Name drive_letter -Value ($sub_type.DriveLetter) -force
				New-Variable -Name disk_type -Value ($sub_type.DriveType) -force
				$device_id = $device_id -replace '\W'
		
				# Converting into perventage
				if($total -and ($total -ne 0)) {
					$temp_usage = 100 - (($free * 100)/$total)
					New-Variable -Name disk_usage -Value $temp_usage -force
				} else {
					New-Variable -Name disk_usage -Value 0 -force
				}
			
				# Rounding up to two decimals
				$disk_usage = [math]::Round($disk_usage,2)
				# calling disk_check 
				disk_check -disk_usage $disk_usage -config_threshold $config -disk_type $disk_type -drive_letter $drive_letter -guid $device_id
			}
		}#type
	} #type_id
	} #flag.Storage ends
	
	if($flag.Network) # Network WIP
	{
	
	$ping_server = $config.Network.ServerName
	#$server_ping = Test-Connection -Computername $server_name -Count 1 | Select ResponseTime
	#$server_ping = $server_ping.ResponseTime
	network_check -ping $ping_server
		
	} #flag.Network
	
	
	### Preparing Alarms ###
	
	### Host's stats
	$alert = get-content -path $alert_path -raw | convertfrom-json # Reading current alarms 
	if($alert) # Retriving severity of alarms 
	{
		if($alert.jsonData.children | where {$_.almModelID -eq 501 -or $_.almModelID -eq 503 -or $_.almModelID -eq 505})
		{
			#memory stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 501 -or $_.almModelID -eq 503 -or $_.almModelID -eq 505} | Select severity
			$stats.jsonData.children.children | where {$_.instance -eq "Memory"} | where {$_.almStatus = $temp.severity}
		}
		if($alert.jsonData.children | where {$_.almModelID -eq 507 -or $_.almModelID -eq 509 -or $_.almModelID -eq 511})
		{
			#Cpu stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 507 -or $_.almModelID -eq 509 -or $_.almModelID -eq 511} | Select severity
			$stats.jsonData.children.children | where {$_.instance -eq "CPU"} | where {$_.almStatus = $temp.severity}
		}
		if($alert.jsonData.children | where {$_.almModelID -eq 513 -or $_.almModelID -eq 515 -or $_.almModelID -eq 517})
		{
			#Disk stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 513 -or $_.almModelID -eq 515 -or $_.almModelID -eq 517} | Select severity
			$temp = $temp.severity
			while($temp)
			{
				if($temp -match "Critical")
				{
					$temp = "CRITICAL"
					break
				}
				elseif($temp -match "Major")
				{
					$temp = "MAJOR"
					break
				}
				elseif($temp -match "Minor")
				{
					$temp = "MINOR"
					break
				}
			} #while
			$stats.jsonData.children.children | where {$_.instance -eq "Disk"} | where {$_.almStatus = $temp}
		}
		if($alert.jsonData.children | where {$_.almModelID -eq 519})
		{
			#Process stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 519} | Select severity
			$temp = $temp.severity
			if($temp)
			{
				$stats.jsonData.children.children | where {$_.instance -eq "Proccesses"} | where {$_.almStatus = "CRITICAL"}
			}
		}
		if($alert.jsonData.children | where {$_.almModelID -eq 521})
		{
			#Services stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 521} | Select severity
			$temp = $temp.severity
			if($temp)
			{
				$stats.jsonData.children.children | where {$_.instance -eq "Services"} | where {$_.almStatus = "CRITICAL"}
			}
		}
		if($alert.jsonData.children | where {$_.almModelID -eq 523})
		{
			#Network stat
			$temp = $alert.jsonData.children | where {$_.almModelID -eq 523} | Select severity
			$temp = $temp.severity
			if($temp)
			{
				$stats.jsonData.children.children | where {$_.instance -eq "Network"} | where {$_.almStatus = "CRITICAL"}
			}
		}
		
		## Overall host's status
		$each_status = $stats.jsonData.children.children.almStatus
	
		if($each_status -Contains "NULL")
		{
			$stats.jsonData.children | where {$_.almStatus = "NULL"}
		}
		if($each_status -Contains "MINOR")
		{
			$stats.jsonData.children | where {$_.almStatus = "MINOR"}
		}
		if($each_status -Contains "MAJOR")
		{
			$stats.jsonData.children | where {$_.almStatus = "MAJOR"}
		}
		if($each_status -Contains "CRITICAL")
		{
			$stats.jsonData.children | where {$_.almStatus = "CRITICAL"}
		} # each_status
		
	} #alert
	
	# Saving stats into json file
	$stats | convertTo-json -Depth 100 | Out-File $stats_path
	
	### Writing Alarm Packets to send to EMS ###
	
	## Initializing Alarm Template
	$alert = get-content -path $alert_path -raw | convertfrom-json
	$alarm_children = get-content -path "$PSScriptRoot\alarm.json" -raw | convertfrom-json	# Reading current alarms
	$alarm_children = $alarm_children.jsonData.children
	$alert_children = $alert.jsonData.children
	$alarm_template = Get-Content $alarm_template_path | ConvertFrom-Json
	$child = $alarm_template.jsonData.children
	
	$alarm_template.jsonData.children = @()
	$alarm_template.jsonData.id.timestamp = $time_stamp	
	$alarm_template.jsonData.id.regionId = $config.Define.regionId
	$alarm_template.jsonData.id.group = $config.Define.group
	$alarm_template.jsonData.id.type = $host_type
	$alarm_template.jsonData.id.serviceName = echo "$host_type-$computer_name"
	$alarm_template.jsonData.id.hostInfo.hostName = $computer_name
	$alarm_template.jsonData.id.hostInfo.HostIp = $computer_IP
	$alarm_template.jsonData.id.hostInfo.version = $config.Define.version
	
	# Storing Alarm MOdel IDs
	$memory_ids = 501, 503, 505
	$memory_ids_cleared = 502, 504, 506
	
	$cpu_ids = 507, 509, 511
	$cpu_ids_cleared = 508, 510, 512
	
	$disk_ids = 513, 515, 517
	$disk_ids_cleared = 514, 516, 518
	
	$process_ids = 519
	$process_ids_cleared = 520
	
	$service_ids = 521
	$sertvice_ids_cleared = 522
	
	$network_ids = 523
	$network_ids_cleared = 524
	
	# Reading Alert File to create Alarm File to send
	foreach ($alert_child in $alert_children)
	{
		if(($memory_ids -contains $alert_child.almModelID) -or ($memory_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "Memory"
		}
		elseif(($cpu_ids -contains $alert_child.almModelID) -or ($cpu_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "CPU"
		}
		elseif(($disk_ids -contains $alert_child.almModelID) -or ($disk_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "Disk"
		}
		elseif(($process_ids -contains $alert_child.almModelID) -or ($process_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "Process"
		}
		elseif(($service_ids -contains $alert_child.almModelID) -or ($service_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "Service"
		}
		elseif(($network_ids -contains $alert_child.almModelID) -or ($network_ids_cleared -contains $alert_child.almModelID))
		{
			$service_type = "Network"
		}
		
		# Memory ID
		if(($memory_ids | ? {$alert_child -match $_}) -or ($memory_ids_cleared | ? {$alert_child -match $_})) 
		{
			if($memory_ids | ? {$alarm_children -match $_})
			{
				$id = $alarm_children | Where {$_.almModelID -eq 501 -or $_.almModelID -eq 503 -or $_.almModelID -eq 505 }
				$id = $id.almID
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# Memory ID
		
		
		# CPU ID
		if(($cpu_ids | ? {$alert_child -match $_}) -or ($cpu_ids_cleared | ? {$alert_child -match $_})) 
		{
			if($cpu_ids | ? {$alarm_children -match $_})
			{
				$id = $alarm_children | Where {$_.almModelID -eq 507 -or $_.almModelID -eq 509 -or $_.almModelID -eq 511 }
				$id = $id.almID
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# CPU ID
		
		# Disk ID
		if(($disk_ids | ? {$alert_child -match $_}) -or ($disk_ids_cleared | ? {$alert_child -match $_})) 
		{	
			$uid = $alert_child.addText | foreach {$_.Split(",")[-1]} 
			$id = $alarm_children | where {$_.specProblem -match $uid}
			$id = $id.almID
			
			if(($disk_ids | ? {$alarm_children -match $_}) -and ($id))
			{
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# Disk ID
		
		# Process ID
		if(($process_ids | ? {$alert_child -match $_}) -or ($process_ids_cleared | ? {$alert_child -match $_})) 
		{	
			$uid = $alert_child.addText | foreach {$_.Split(" ")[0]} 
			$id = $alarm_children | where {$_.specProblem -match $uid}
			$id = $id.almID
			
			if(($process_ids | ? {$alarm_children -match $_}) -and ($id))
			{
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# Process ID
		
		# Service ID
		if(($service_ids | ? {$alert_child -match $_}) -or ($service_ids_cleared | ? {$alert_child -match $_})) 
		{	
			$uid = $alert_child.addText | foreach {$_.Split(" ")[0]}
			$id = $alarm_children | where {$_.specProblem -match $uid}
			$id = $id.almID
			
			if(($service_ids | ? {$alarm_children -match $_}) -and ($id))
			{
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# Service ID
		
		# Network ID
		if(($network_ids | ? {$alert_child -match $_}) -or ($network_ids_cleared | ? {$alert_child -match $_})) 
		{	
			$uid = $alert_child.addText | foreach {$_.Split(" ")[0]} 
			$id = $alarm_children | where {$_.specProblem -match $uid}
			$id = $id.almID
			
			if(($network_ids | ? {$alarm_children -match $_}) -and ($id))
			{
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			
			}else{
				$id = $id_counter.jsonData.id 
				increase_counter
			
				$child = $child | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$child.almID = $id 
				$child.almModelID = $alert_child.almModelID
				$child.almTime = (Get-Date).toString()
				$child.instance = echo "/$host_type=$computer_name/$service_type"
				$child.specProblem = $alert_child.addText
				$alarm_template.jsonData.children += $child
			}	
		}# Network ID

	}# foreach alert_child
	
	# Writing Alarm that will be sent to EMS
	$alarm_template | ConvertTo-Json -Depth 100 | Out-File $alarm_path
	
	##########################################################
	
	### Sending to EMS ###
	$send_to_ems = "true"
	$EMS_URI = $config.Define.EMS_URI
	
	## Seinding stats
	if($send_to_ems)
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$uri = "$EMS_URI/state"
		$stats = Get-Content "$PSScriptRoot\stats.json"
			
		Invoke-RestMethod -uri $uri -Method Post -Body ($stats) -ContentType "application/json"
	}
		
	## Seinding alarm 
	if($send_to_ems)
	{
		[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
		$uri = "$EMS_URI/alarm"
		$alarm = Get-Content "$PSScriptRoot\alarm.json"
		
		Invoke-RestMethod -uri $uri -Method Post -Body ($alarm) -ContentType "application/json"
	}
		
} #try
catch
{
	# Writing exceptions to Error file
	$_ |timestamp | add-content $ErrorLog 
}
