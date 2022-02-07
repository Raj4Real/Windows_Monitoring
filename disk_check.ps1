
### Function to write Disk/Storage alarms to json file

function disk_check($disk_usage, $config_threshold, $disk_type, $drive_letter, $guid) {

	#$id = $id_counter.jsonData.id 
	
	if($disk_usage -lt $config_threshold.Disk.DISKCRITICAL){
		if($disk_usage -lt $config_threshold.Disk.DISKMAJOR){
			if($disk_usage -lt $config_threshold.Disk.DISKMINOR){
			
				#echo "$disk_type and $drive_letter Disk Usage is Normal"

				if($alert.jsonData.children.almModelID -eq 513 -and $alert.jsonData.children.addText -match $guid) {
					#echo "$disk_type and $drive_letter Disk Minor cleared";
					
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 514 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 514 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 514 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 514 -and $_.addText -eq "" } | foreach { $_.addText = echo "type $disk_type, $drive_letter usage is $disk_usage%, $guid" }
					#$id++
				}
				elseif($alert.jsonData.children.almModelID -eq 515 -and $alert.jsonData.children.addText -match $guid) {
					#echo "Disk Major is cleared"
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 516 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 516 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 516 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 516 -and $_.addText -eq "" } | foreach { $_.addText = echo "type $disk_type, $drive_letter Disk usage is $disk_usage%, $guid" }
					#$id++
				}
				elseif($alert.jsonData.children.almModelID -eq 517 -and $alert.jsonData.children.addText -match $guid) {
					#echo "Disk Critical is Cleared"
				
					$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 518 }
					$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
					$template.jsonData.children += $test
					#$template.jsonData.children | where { $_.almModelID -eq 518 -and $_.almID -eq "" } | foreach {$_.almID = $id}
					#$template.jsonData.children | where { $_.almModelID -eq 518 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
					$template.jsonData.children | where { $_.almModelID -eq 518 -and $_.addText -eq "" } | foreach { $_.addText = echo "type $disk_type, $drive_letter Disk usage is $disk_usage%, $guid" }
					#$id++
				}
			
			} else { #echo "Disk usage is Minor level" 
			
				$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 513 }
				$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
				$template.jsonData.children += $test
				#$template.jsonData.children | where { $_.almModelID -eq 513 -and $_.almID -eq "" } | foreach { $_.almID = $id }
				#$template.jsonData.children | where { $_.almModelID -eq 513 -and $_.almID -eq $id} | foreach { $_.time = (Get-Date).toString() }
				$template.jsonData.children | where { $_.almModelID -eq 513 -and $_.addText -eq "" } | foreach { $_.addText = echo "type $disk_type, $drive_letter Disk usage is $disk_usage%, $guid" }
				#$id++
				}
		} else { #echo "Disk usage is Major level" 
		
			$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 515 }
			$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
			$template.jsonData.children += $test
			#$template.jsonData.children | where { $_.almModelID -eq 513 -and $_.almID -eq ""} | foreach { $_.almID = $id }
			#$template.jsonData.children | where { $_.almModelID -eq 515 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
			$template.jsonData.children | where { $_.almModelID -eq 515 -and $_.addText -eq ""} | foreach { $_.addText = echo "type $disk_type, $drive_letter Disk usage is $disk_usage%, $guid" }
			#$id++
			}	
	} else { #echo "Disk usage is Critical"
	
		$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 517 }
		$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
		$template.jsonData.children += $test
		#$template.jsonData.children | where { $_.almModelID -eq 513 -and $_.almID -eq ""} | foreach { $_.almID = $id }
		#$template.jsonData.children | where { $_.almModelID -eq 517 -and $_.almID -eq $id} | foreach { $_.time = (Get-Date).toString() }
		$template.jsonData.children | where { $_.almModelID -eq 517 -and $_.addText -eq "" } | foreach { $_.addText = echo "type $disk_type, $drive_letter Disk usage is $disk_usage%, $guid" }
		#$id++
		}
	$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
	#$id_counter.jsonData.id = $id
	#$id_counter | ConvertTo-Json -Depth 100 | Out-File $id_counter_path
} #disk_check