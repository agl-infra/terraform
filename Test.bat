winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" profile=public protocol=tcp localport=5985 remoteip=localsubnet new remoteip=any
