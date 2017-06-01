<script>
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  $admin = [ADSI]("WinNT://./administrator, user")
  $admin.SetPassword("${windows_admin_password}")
  netsh advfirewall set allprofiles state off
  Restart-Service docker
  Start-Sleep -s 5
  mkdir C:\k8s
  Start-Process docker.exe -ArgumentList "pull microsoft/nanoserver" -RedirectStandardOutput "C:\k8s\docker_pull_microsoft_nanoserver.log"
  Start-Process docker.exe -ArgumentList "pull microsoft/windowsservercore" -RedirectStandardOutput "C:\k8s\docker_pull_microsoft_windowsservercore.log"
</powershell>