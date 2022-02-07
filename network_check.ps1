### Function to check network pings and write alarms to json file

function network_check($ping) {
	
	foreach ($p in $ping)
	{
		#$id = $id_counter.jsonData.id 
		$ping = New-Object System.Net.NetworkInformation.Ping
		try
		{
			$ping = $ping.Send($p)
			$status = $ping.Status
		}
		catch
		{
			echo "Invalid Host Name, $p"
		}
		$latency = $ping.RoundtripTime
	
		if($status -eq "Success")
		{
			# No trigger
			# check for alarm clear 
			$check_clear = $alert.jsonData.children | where {$_.almModelID -eq 523 -and $_.addText -match $p}
			if($check_clear)
			{
				$temp = $alarm_model.jsonData.children | Where {$_.almModelID -eq 524}
				$temp = $temp | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$template.jsonData.children += $temp
				#$template.jsonData.children | where {$_.almModelID -eq 524 -and $_.addText -eq ""} | foreach {$_.almID = $id}
				#$template.jsonData.children | where {$_.almModelID -eq 524 -and $_.almID -eq $id} | foreach {$_.time = (Get-Date).ToString()}
				$template.jsonData.children | where {$_.almModelID -eq 524 -and $_.addText -eq ""} | foreach {$_.addText ="$p is reachable now"}
				#$id++
				
				$template | ConvertTo-json -Depth 100 | Out-file $alert_path
				#$id_counter.jsonData.id = $id
				#$id_counter | ConvertTo-Json -Depth 100 | Out-File $id_counter_path
				
			} else {
				$template | ConvertTo-json -Depth 100 | Out-file $alert_path
			}
			# check for latency
			if($latency -gt 30000)
			{
				# trigger alarm
				$temp = $alarm_model.jsonData.children | Where {$_.almModelID -eq 523}
				$temp = $temp | ConvertTo-Json -Depth 100 | ConvertFrom-Json
				$template.jsonData.children += $temp
				#$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.almID -eq ""} | foreach {$_.almID = $id}
				#$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.almID -eq $id} | foreach {$_.time = (Get-Date).ToString()}
				$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.addText -eq ""} | foreach {$_.addText ="$p latency is over 30s"}
				#$id++
				
				$template | ConvertTo-json -Depth 100 | Out-file $alert_path
				#$id_counter.jsonData.id = $id
				#$id_counter | ConvertTo-Json -Depth 100 | Out-File $id_counter_path
			} #latency
		}
		elseif($status -eq "TimedOut")
		{
			# trigger alarm
			$temp = $alarm_model.jsonData.children | Where {$_.almModelID -eq 523}
			$temp = $temp | ConvertTo-Json -Depth 100 | ConvertFrom-Json
			$template.jsonData.children += $temp
			#$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.almID -eq ""} | foreach {$_.almID = $id}
			#$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.almID -eq $id} | foreach {$_.time = (Get-Date).ToString()}
			$template.jsonData.children | where {$_.almModelID -eq 523 -and $_.addText -eq ""} | foreach {$_.addText ="$p is not reachable"}
			#$id++
				
			$template | ConvertTo-json -Depth 100 | Out-file $alert_path
			#$id_counter.jsonData.id = $id
			#$id_counter | ConvertTo-Json -Depth 100 | Out-File $id_counter_path
		}
	} #$p foreach

} #cpu_check