$limit = (Get-Date).AddDays(-15)
$path = "F:\"

# Delete files older than the $limit.
Get-ChildItem -Path $path -Recurse -Force -filter *.log | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force

