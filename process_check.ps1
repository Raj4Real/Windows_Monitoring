
### Function to get processes and write alarms to json file

function process_check($process, $computer_name) {

	$temp_process = $NULL
	$disable = $config.Disable.Processes 
	#$id = $id_counter.jsonData.id
	
	if($disable)
	{
		$process = $process | Where-Object {$disable -notContains $_}

	} #disable
	
	foreach($proc in $process)
	{
		$temp_process = get-process $proc -computername $computer_name -ErrorAction SilentlyContinue
		if($temp_process -eq $NULL){
			#echo "Process $proc is not running"
			$process_stopped += $proc
			$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 519 }
			$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
			$template.jsonData.children += $test
			$template.jsonData.children | where { $_.almModelID -eq 519 -and $_.addText -eq "" } | foreach { $_.addText = echo "$proc is not running" } 
			#$template.jsonData.children | where { $_.almModelID -eq 519 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
			#$template.jsonData.children | where { $_.almModelID -eq 519 } | foreach { $_.addText = echo "$proc is not running" } 	
		}
		else {
			#echo "Process $proc is running"
			$process_running += $temp_process
			$check_clear = $alert.jsonData.children | where {$_.almModelID -eq 519 -and $_.addText -match $proc}
		
			if($check_clear){
				$test = $alarm_model.jsonData.children | where { $_.almModelID -eq 520 }
				$test = $test | ConvertTo-Json -Depth 100 | ConvertFrom-json
				$template.jsonData.children += $test
				#$template.jsonData.children | where { $_.almModelID -eq 520 -and $_.almID -eq "" } | foreach { $_.almID = $id }
				#$template.jsonData.children | where { $_.almModelID -eq 520 -and $_.almID -eq $id } | foreach { $_.time = (Get-Date).toString() }
				$template.jsonData.children | where { $_.almModelID -eq 520 -and $_.addText -eq "" } | foreach { $_.addText = echo "$proc is now running" } 			
			} #check_clear
		}
	}
	$template | ConvertTo-Json -Depth 100 | Out-File $alert_path
} #process_check