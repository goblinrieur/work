# notes & useful commands :

## connection settings : 

```
start-service sshd
```

### more specific trust settings

```
set-item WSMan:\localhost\Client\TrustedHosts -Value "10.12.9.xxx"

Enter-PSSession -ComputerName 10.12.9.xxx -Credential Administrator
```

### sending files

```
# be careful about the windows path syntax and double backslashes
scp  script.ps1   SomeUser@ip.ip.ip.ip:f:\\
# in some case like for receiving binary files you need to add -t
scp SomeUser@ip.ip.ip.ip:f:\\SomeFile.dat ./
```

## check & manage disk space 

```
Get-WmiObject -Class Win32_logicaldisk
```

## change a hostname

```
$computerName = Get-WmiObject Win32_ComputerSystem
$name = Read-Host -Prompt "Enter new computer name: "
$computerName.Rename($name)
```

this needs a reboot.


