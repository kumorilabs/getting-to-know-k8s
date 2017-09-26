<script>
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
  $admin = [ADSI]("WinNT://./administrator, user")
  $admin.SetPassword("${windows_admin_password}")
  netsh advfirewall set allprofiles state off
</powershell>