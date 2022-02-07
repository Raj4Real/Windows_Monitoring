### Function to write Memory/RAM alarms to json file

function memory_check($ram_usage, $config_threshold, $guid) {

	if($ram_usage -lt $config_threshold.Memory.MEMCRITICAL){
		if($ram_usage -lt $config_threshold.Memory.MEMMAJOR){
			if($ram_usage -lt $config_threshold.Memory.MEMMINOR){
			
				#echo "RAM Usage is Normal"

				if($alert.jsonData.children.almModelID -eq 501) {
					#echo "RAM Minor cleared";
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 502 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 502 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 502 } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 502 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
					
				}
				elseif($alert.jsonData.children.almModelID -eq 503) {
					#echo "RAM Major is cleared"
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 504 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 504 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 504 } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 504 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				
				}
				elseif($alert.jsonData.children.almModelID -eq 505) {
					#echo "RAM Critical is Cleared"
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 506 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 506 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 506 } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 506 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
					$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
					
				}
			
			} else { #echo "RAM usage is Minor level" 
			
				$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 501 }
				$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
				$template.jsonData.children += $test
				#$template.jsonData.children | where { $_.almModelID -eq 501 }
				#$template.jsonData.children | where { $_.almModelID -eq 501 } | foreach { $_.time = (Get-Date).toString() }
				$template.jsonData.children | where { $_.almModelID -eq 501 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
				$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
				
				}
		} else { #echo "RAM usage is Major level" 
		
			$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 503 }
			$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
			$template.jsonData.children += $test
			#$template.jsonData.children | where { $_.almModelID -eq 503 -and $_.almID -eq "" } | foreach {$_.almID = $id}
			#$template.jsonData.children | where { $_.almModelID -eq 503 } | foreach { $_.time = (Get-Date).toString() }
			$template.jsonData.children | where { $_.almModelID -eq 503 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
			$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
			
			}	
	} else { #echo "RAM usage is Critical"
	
		$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 505 }
		$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
		$template.jsonData.children += $test
		#$template.jsonData.children | where { $_.almModelID -eq 505 -and $_.almID -eq "" } | foreach {$_.almID = $id}
		#$template.jsonData.children | where { $_.almModelID -eq 505 } | foreach { $_.time = (Get-Date).toString() }
		$template.jsonData.children | where { $_.almModelID -eq 505 } | foreach { $_.addText = echo "RAM usage is $ram_usage%" }
		$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
		
		}
	$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
	
} #memory_check