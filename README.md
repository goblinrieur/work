# notes & useful commands for powershell :

## connection settings :

```
start-service sshd
```

### more specific trust settings

```
set-item WSMan:\localhost\Client\TrustedHosts -Value "10.12.9.xxx"

Enter-PSSession -ComputerName 10.12.9.xxx -Credential Administrator
```

## sending files

```
# be careful about the windows path syntax and double backslashes
scp  script.ps1   SomeUser@ip.ip.ip.ip:f:\\
# in some case like for receiving binary files you need to add -t
scp SomeUser@ip.ip.ip.ip:f:\\SomeFile.dat ./
```

## remote access windows

en powershell :

```
cmdkey /generic:"server01" /user:"test" /pass:"PW"
mstsc /v:server01
```

## check & manage disk space

```
Get-WmiObject -Class Win32_logicaldisk
```

### change a hostname

```
$computerName = Get-WmiObject Win32_ComputerSystem
$name = Read-Host -Prompt "Enter new computer name: "
$computerName.Rename($name)
```

this needs a reboot.

# files in there

| **format** | **file**                    | **comment**                                                                         |
|:----------:|:---------------------------:|:-----------------------------------------------------------------------------------:|
| text       | LICENSE                     | /\* no comment \*/                                                                  |
| text       | README\.md                  | /\* no comment \*/                                                                  |
| bash       | gitclone\_allatonce\.sh     | get all repos from a project, organisation or user at once\. \(permissions needed\) |
| bash       | gitlog\_nice\.sh            | display nicely & easy to read commit tree history                                   |
| bash       | update\.sh                  | update & fetch/pull all of a repo list to local work directory                      |
| powershell | list\_most\_big\_files\.ps1 | find & list bigger files from a  drive for monitoring & avoid space issues          |
| powershell | purge\_old\_log\.ps1        | find & delete old log files\.                                                       |


