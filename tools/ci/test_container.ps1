docker run --detach --name alloyTest ptodev/alloy:latest

Write-Host "Checking if the container is running..."
$success = false
$log = ""
$i=1
for(;$i -le 60;$i++)
{
  Start-Sleep -Seconds 1
  $log = docker logs alloyTest
  if ($log -contains "finished node evaluation")
  {
    $success = $true
    Write-Host "Container is running successfully."
    break
  }
}

if ($success)
{
  Write-Host "Container ran successfully."
  Write-Host "Container failed to run. Check the logs for more details:\n", $log 
}
else
{
  Write-Error "Container failed to run. Check the logs for more details:\n", $log 
  exit 1
}
