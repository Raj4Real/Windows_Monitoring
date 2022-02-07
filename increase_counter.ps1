Function increase_counter()
{
	echo $id
	$id++
	$id_counter.jsonData.id = $id
	$id_counter | ConvertTo-Json -Depth 100 | Out-File $id_counter_path
	
}