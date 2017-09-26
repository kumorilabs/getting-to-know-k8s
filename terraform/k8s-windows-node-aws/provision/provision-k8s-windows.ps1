<#
    .SYNOPSIS
        Provisions a VM as a Kubernetes agent in AWS

    .DESCRIPTION
        Provisions a VM as a Kubernetes agent in AWS
#>
[CmdletBinding(DefaultParameterSetName="Standard")]
param(
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $AWSHostname,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $AWSK8sWinHostNic1,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $AWSK8sWinHostNic2,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $AWSK8sWinHostNic3,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $KubeDnsServiceIp,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $NonMasqCIDR,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $K8sVersion
)

$global:KubeDir = "c:\k8s"
$global:7ZipBinariesURL = "http://www.7-zip.org/a/7za920.zip"
$global:KubeBinariesURL = "https://dl.k8s.io/v" + ${K8sVersion} + "/kubernetes-node-windows-amd64.tar.gz"
$global:NSSMBinariesURL = "https://nssm.cc/release/nssm-2.24.zip" 
$global:KubeletStartFile = $global:KubeDir + "\Start-Kubelet.ps1"
$global:KubeProxyStartFile = $global:KubeDir + "\Start-Kube-proxy.ps1"
$global:TransparentNetworkName = "TransparentNet"
$global:VMSwitchNetworkName = "KubeProxySwitch"
$global:PodInfraContainerName = "apprenda/pause"


filter Timestamp {"$(Get-Date -Format o): $_"}

function
Write-Log($message)
{
    $msg = $message | Timestamp
    Write-Output $msg
}


function
Set-BaseNetwork()
{
    $nic1 = Get-NetIPAddress | Where-Object IPAddress -Eq ${AWSK8sWinHostNic1} | Select -ExpandProperty InterfaceAlias
    $nic2 = Get-NetIPAddress | Where-Object IPAddress -Eq ${AWSK8sWinHostNic2} | Select -ExpandProperty InterfaceAlias
    $nic3 = Get-NetIPAddress | Where-Object IPAddress -Eq ${AWSK8sWinHostNic3} | Select -ExpandProperty InterfaceAlias

    Get-NetAdapter -Name $nic1 | Rename-NetAdapter -NewName "nic-1-external" -PassThru
    Get-NetAdapter -Name $nic2 | Rename-NetAdapter -NewName "nic-2-docker" -PassThru
    Get-NetAdapter -Name $nic3 | Rename-NetAdapter -NewName "nic-3-internal" -PassThru

    Remove-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "nic-2-docker" -AsJob
    Remove-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceAlias "nic-3-internal" -AsJob

    New-NetRoute -DestinationPrefix ${NonMasqCIDR} -InterfaceAlias "nic-3-internal"
}


function
Get-KubeBinaries()
{
    cd $global:KubeDir
    do{sleep 10;(New-Object System.Net.WebClient).DownloadFile("$global:7ZipBinariesURL", "$global:KubeDir\7z.zip")}while(!$?);&"$global:KubeDir\7z.zip"
    Expand-Archive .\7z.zip -DestinationPath .\7z\
    mv 7z\7za.exe .
    do{sleep 10;(New-Object System.Net.WebClient).DownloadFile("$global:KubeBinariesURL", "$global:KubeDir\kubernetes-node-windows-amd64.tar.gz")}while(!$?);&"$global:KubeDir\kubernetes-node-windows-amd64.tar.gz"
    cmd /c "$global:KubeDir\7za.exe e kubernetes-node-windows-amd64.tar.gz"
    cmd /c "$global:KubeDir\7za.exe x kubernetes-node-windows-amd64.tar"
    mv kubernetes\node\bin\*.exe .
    Remove-Item -Recurse -Force kubernetes
    Remove-Item -Recurse -Force kubernetes-node-windows-amd64*
    Remove-Item -Recurse -Force 7z*   
}


function
Get-NSSMBinary()
{
    cd $global:KubeDir
    do{sleep 10;(New-Object System.Net.WebClient).DownloadFile("$global:NSSMBinariesURL", "$global:KubeDir\nssm.zip")}while(!$?);&"$global:KubeDir\nssm.zip"
    Expand-Archive .\nssm.zip -DestinationPath .
    mv nssm-2.24\win64\nssm.exe .
    Remove-Item -Recurse -Force nssm.zip
    Remove-Item -Recurse -Force nssm-2.24
}


function
Get-InfraContainer()
{
    Restart-Service docker
    Start-Sleep -s 5
    docker pull $global:PodInfraContainerName
}


function
Get-PodCIDR
{
    $argList = @("--hostname-override=${AWSHostname}","--pod-infra-container-image=${global:PodInfraContainerName}","--resolv-conf=""""","--kubeconfig=${global:KubeDir}\config","--require-kubeconfig")
    $process = Start-Process -FilePath $global:KubeDir\kubelet.exe -PassThru -ArgumentList $argList

    $podCIDRDiscovered=$false
    $podCIDR=""
    # Run Kubelet until podCidr is discovered
    Write-Host "Waiting to discover the pod CIDR"
    while (-not $podCIDRDiscovered)
    {
        $podCIDR=C:\k8s\kubectl.exe --kubeconfig=${global:KubeDir}\config get nodes/$(${AWSHostname}.ToLower()) -o custom-columns=podCidr:.spec.podCIDR --no-headers

        if ($podCIDR.length -gt 0)
        {
            $podCIDRDiscovered=$true
        }
        else
        {
            Write-Host "Sleeping for 10s, and then try again to discover pod CIDR"
            Start-Sleep -sec 10    
        }
    }
    
    # Stop the Kubelet process now that we have our CIDR, discard the process output
    $process | Stop-Process | Out-Null
    
    return $podCIDR
}


function
Get-PodGateway($podCIDR)
{
    return $podCIDR.substring(0,$podCIDR.lastIndexOf(".")) + ".1"
}


function
Write-KubernetesStartFiles($podCIDR)
{
    $podGW=Get-PodGateway($podCIDR)

    $kubeConfig = @"
`$env:CONTAINER_NETWORK="${global:TransparentNetworkName}"
${global:KubeDir}\kubelet.exe --hostname-override=${AWSHostname} --pod-infra-container-image=${global:PodInfraContainerName} --resolv-conf="" --allow-privileged=true --enable-debugging-handlers=true --cluster-dns=${KubeDnsServiceIp} --cluster-domain=cluster.local  --kubeconfig=${global:KubeDir}\config --require-kubeconfig --hairpin-mode=promiscuous-bridge --v=2 --non-masquerade-cidr=${NonMasqCIDR}
"@
    $kubeConfig | Out-File -encoding ASCII -filepath $global:KubeletStartFile

    $kubeProxyStartStr = @"
`$env:INTERFACE_TO_ADD_SERVICE_IP="vEthernet (${global:VMSwitchNetworkName})"
$global:KubeDir\kube-proxy.exe --v=3 --proxy-mode=userspace --hostname-override=${AWSHostname} --kubeconfig=${global:KubeDir}\config --bind-address=${AWSK8sWinHostNic1}
"@

    $kubeProxyStartStr | Out-File -encoding ASCII -filepath $global:KubeProxyStartFile
}


function
Set-DockerNetwork($podCIDR)
{
    $podGW=Get-PodGateway($podCIDR)

    # Reduce MTU for both network interfaces to stop RDP from breaking
    netsh interface ipv4 set interface "nic-1-external" mtu=1430 store=persistent
    netsh interface ipv4 set interface "nic-2-docker" mtu=1430 store=persistent
    netsh interface ipv4 set interface "nic-3-internal" mtu=1430 store=persistent

    # Turn off Firewall to enable pods to talk to service endpoints
    netsh advfirewall set allprofiles state off

    # Create new transparent network
    docker network create --driver=transparent --subnet=${podCIDR} --gateway=${podGW} -o com.docker.network.windowsshim.interface="nic-2-docker" -o com.docker.network.windowsshim.dnsservers=${KubeDnsServiceIp} ${global:TransparentNetworkName}

    # Set IP address for Transparent network
    netsh interface ipv4 add address "vEthernet (HNSTransparent)" ${podGW} 255.255.255.0

    # Create VMSwitch for kube-proxy
    New-VMSwitch -Name ${global:VMSwitchNetworkName} -SwitchType Internal

    # Enable forwarding on host adapters
    netsh interface ipv4 set interface "vEthernet (${global:VMSwitchNetworkName})" for=en
    netsh interface ipv4 set interface "vEthernet (HNSTransparent)" for=en
    netsh interface ipv4 set interface "nic-1-external" for=en
    netsh interface ipv4 set interface "nic-3-internal" for=en
}


function
Set-RoutingNat()
{
    # Install and enable RRAS
    Install-WindowsFeature Routing -IncludeManagementTools
    Install-RemoteAccess -VpnType Vpn

    # Pause for 30 seconds
    sleep 30

    # Configure RRAS for NAT to enable external connectivity from pods
    netsh routing ip nat install
    sleep 30
    netsh routing ip nat add interface "nic-1-external"
    sleep 30
    netsh routing ip nat set interface "nic-1-external" mode=full 
}


function
New-NSSMService
{
    # Setup Kubelet service
    C:\k8s\nssm install Kubelet C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
    C:\k8s\nssm set Kubelet AppDirectory $global:KubeDir
    C:\k8s\nssm set Kubelet AppParameters $global:KubeletStartFile
    C:\k8s\nssm set Kubelet DisplayName Kubelet
    C:\k8s\nssm set Kubelet Description Kubelet
    C:\k8s\nssm set Kubelet Start SERVICE_AUTO_START
    C:\k8s\nssm set Kubelet ObjectName LocalSystem
    C:\k8s\nssm set Kubelet Type SERVICE_WIN32_OWN_PROCESS
    C:\k8s\nssm set Kubelet AppThrottle 1500
    C:\k8s\nssm set Kubelet AppStdout $global:KubeDir\kubelet.log
    C:\k8s\nssm set Kubelet AppStderr $global:KubeDir\kubelet.err.log
    C:\k8s\nssm set Kubelet AppStdoutCreationDisposition 4
    C:\k8s\nssm set Kubelet AppStderrCreationDisposition 4
    C:\k8s\nssm set Kubelet AppRotateFiles 1
    C:\k8s\nssm set Kubelet AppRotateOnline 1
    C:\k8s\nssm set Kubelet AppRotateSeconds 86400
    C:\k8s\nssm set Kubelet AppRotateBytes 1048576
    net start Kubelet
    
    # Setup Kube-proxy Service
    C:\k8s\nssm install Kubeproxy C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
    C:\k8s\nssm set Kubeproxy AppDirectory $global:KubeDir
    C:\k8s\nssm set Kubeproxy AppParameters $global:KubeProxyStartFile
    C:\k8s\nssm set Kubeproxy DisplayName Kubeproxy
    C:\k8s\nssm set Kubeproxy DependOnService Kubelet
    C:\k8s\nssm set Kubeproxy Description Kubeproxy
    C:\k8s\nssm set Kubeproxy Start SERVICE_AUTO_START
    C:\k8s\nssm set Kubeproxy ObjectName LocalSystem
    C:\k8s\nssm set Kubeproxy Type SERVICE_WIN32_OWN_PROCESS
    C:\k8s\nssm set Kubeproxy AppThrottle 1500
    C:\k8s\nssm set Kubeproxy AppStdout $global:KubeDir\kubeproxy.log
    C:\k8s\nssm set Kubeproxy AppStderr $global:KubeDir\kubeproxy.err.log
    C:\k8s\nssm set Kubeproxy AppRotateFiles 1
    C:\k8s\nssm set Kubeproxy AppRotateOnline 1
    C:\k8s\nssm set Kubeproxy AppRotateSeconds 86400
    C:\k8s\nssm set Kubeproxy AppRotateBytes 1048576
    net start Kubeproxy
}

function
Set-Explorer
{
    # Setup explorer so that it is usable
    New-Item -Path HKLM:"\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer"
    New-Item -Path HKLM:"\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\BrowserEmulation"
    New-ItemProperty -Path HKLM:"\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\BrowserEmulation" -Name IntranetCompatibilityMode -Value 0 -Type DWord
    New-Item -Path HKLM:"\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\Main"
    New-ItemProperty -Path HKLM:"\\SOFTWARE\\Policies\\Microsoft\\Internet Explorer\\Main" -Name "Start Page" -Type String -Value http://bing.com
}

try
{
    # Set to false for debugging
    if ($true) {
        Write-Log "Setting up K8s Windows Node..."

        Write-Log "Setup the base network"
        Set-BaseNetwork
    
        Write-Log "Download Kubernetes binaries"
        Get-KubeBinaries

        Write-Log "Download NSSM binary"
        Get-NSSMBinary

        Write-Log "Download the pause container for Kubelet"
        Get-InfraContainer

        Write-Log "Get the POD CIDR"
        $podCIDR = Get-PodCIDR

        Write-Log "Write Kubelet startfile with pod CIDR of $podCIDR"
        Write-KubernetesStartFiles $podCIDR

        Write-Log "Setup Docker network with pod CIDR of $podCIDR"
        Set-DockerNetwork $podCIDR

        Write-Log "Setup Routing and Remote Access for NAT"
        Set-RoutingNat

        Write-Log "Install the NSSM services"
        New-NSSMService

        Write-Log "Setup Internet Explorer"
        Set-Explorer

        Write-Log "Setup Complete"
    }
    else 
    {
        # Keep for debugging purposes
        Write-Log ".\provision-k8s-windows.ps1 -AWSHostname $AWSHostname -AWSK8sWinHostNic1 $AWSK8sWinHostNic1 -AWSK8sWinHostNic2 $AWSK8sWinHostNic2 -AWSK8sWinHostNic3 $AWSK8sWinHostNic3 -KubeDnsServiceIp $KubeDnsServiceIp -NonMasqCIDR $NonMasqCIDR -K8sVersion $K8sVersion"
    }
}
catch
{
    Write-Error $_
}
