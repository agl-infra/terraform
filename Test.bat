cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
cmd.exe /c winrm set winrm/config '@{MaxTimeoutms="1800000"}'
cmd.exe /c netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any
