
### Function to check Services and write alarms to json file

function service_check($service, $computer_name) {

	$temp_service = $NULL
	$disable = $config.Disable.Services 
	#$id = $id_counter.jsonData.id
	
	if($disable)
	{
		$service = $service | Where-Object {$disable -notContains $_}
	} #disable

	foreach($proc in $service)
	{
		$temp_service = get-service $proc -computername $computer_name -ErrorAction SilentlyContinue
		if($temp_service.Status -eq "Stopped"){
			$temp = $temp_service.Name
			#echo "Service $temp is not running"
			$process_stopped += $proc
			$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 521 }
			$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
			$template.jsonData.children += $test
			#$template.jsonData.children | where { $_.almModelID -eq 521 -and $_.almID -eq "" } | foreach { $_.almID = $id }
			#$template.jsonData.children | where { $_.almModelID -eq 521 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
			$template.jsonData.children | where { $_.almModelID -eq 521 -and $_.addText -eq "" } | foreach { $_.addText = echo "$proc is not running" } 	
			
		}
		elseif($temp_service.Status -eq "Running") {
			$temp = $temp_service.Name
			#echo "Service $temp is running"
			$process_running += $temp_service
			$check_clear = $alert.jsonData.children | where {$_.almModelID -eq 521 -and $_.addText -match $proc}
		
			if($check_clear){
				$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 522 }
				$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
				$template.jsonData.children += $test
				#$template.jsonData.children | where { $_.almModelID -eq 522 -and $_.almID -eq "" } | foreach { $_.almID = $id }
				#$template.jsonData.children | where { $_.almModelID -eq 522 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
				$template.jsonData.children | where { $_.almModelID -eq 522 -and $_.addText -eq "" } | foreach { $_.addText = echo "$proc is now running" } 			
			} #check_clear
		}
		elseif($temp_service.Status -eq $NULL){
			#echo "service not found"
		}
	}
	$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
	
} #service_check