$refDate = (Get-Date).AddDays(-30).Date
# fill the list of binary filetypes that are most likely found
$binaries = '*.lib','*.dat','*.zip','*.jar','*.pdb','*.exe', '*.bin', '*.png', '*.gif', '*.jpg', '*.dll'  # etcetera

Get-ChildItem -File -Recurse -Exclude $binaries | 
    Where-Object {$_.LastWriteTime -lt $refDate} | 
    Sort-Object Length -Descending |
    Select-Object -First 10 | 
    Select-Object Fullname, Length   # I would use FullName as you are using recursion..
