
### Function to write CPU alarms to json file

function cpu_check($cpu_usage, $config_threshold, $guid) {
	
	if($cpu_usage -lt $config_threshold.CPU.CPUCRITICAL){
		if($cpu_usage -lt $config_threshold.CPU.CPUMAJOR){
			if($cpu_usage -lt $config_threshold.CPU.CPUMINOR){
			
				#echo "CPU Usage is Normal"
				 
				if($alert.jsonData.children.almModelID -eq 507) {
					#echo "CPU Minor cleared";
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 508 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 508 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 508 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 508 -and $_.almID -eq $id } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				}
				elseif($alert.jsonData.children.almModelID -eq 509) {
					#echo "CPU Major is cleared"
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 510 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 510 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 510 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 510 } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				}
				elseif($alert.jsonData.children.almModelID -eq 511) {
					#echo "CPU Critical is Cleared"
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 512 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 512 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 512 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 512 } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				}
						
			} else { #echo "CPU usage is Minor level" 
			
				
				$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 507 }
				$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
				$template.jsonData.children += $test
				#$template.jsonData.children | where { $_.almModelID -eq 507 -and $_.almID -eq "" } | foreach {$_.almID = $id}
				#$template.jsonData.children | where { $_.almModelID -eq 507 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
				$template.jsonData.children | where { $_.almModelID -eq 507 } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
				$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				}
		} else { #echo "CPU usage is Major level" 
		
			$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 509 }
			$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
			$template.jsonData.children += $test
			#$template.jsonData.children | where { $_.almModelID -eq 509 -and $_.almID -eq "" } | foreach {$_.almID = $id}
			#$template.jsonData.children | where { $_.almModelID -eq 509 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
			$template.jsonData.children | where { $_.almModelID -eq 509 } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
			$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
			}	
	} else { #echo "CPU usage is Critical"
	
		$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 511 }
		$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
		$template.jsonData.children += $test
		#$template.jsonData.children | where { $_.almModelID -eq 511 -and $_.almID -eq "" } | foreach {$_.almID = $id}
		#$template.jsonData.children | where { $_.almModelID -eq 511 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
		$template.jsonData.children | where { $_.almModelID -eq 511 } | foreach { $_.addText = echo "CPU usage is $cpu_usage%" }
		$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
		}
	$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
} #cpu_check