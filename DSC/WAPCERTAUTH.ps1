Configuration WAPCERTAUTH
{
   param
   (
        [String]$NetBiosDomain,
        [String]$ExchangeExistsVersion,
        [String]$EXServerIP,
        [String]$ExternalDomainName,
        [System.Management.Automation.PSCredential]$Admincreds
 
    )

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${NetBiosDomain}\$($AdminCreds.UserName)", $AdminCreds.Password)
 
    Node localhost
    {
        Script AllowRemoteCopy
        {
            SetScript =
            {
                # Allow Remote Copy
                $winrmserviceitem = get-item -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRm\Service" -ErrorAction 0
                $allowunencrypt = get-itemproperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRm\Service" -Name "AllowUnencryptedTraffic" -ErrorAction 0
                $allowbasic = get-itemproperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRm\Service" -Name "AllowBasic" -ErrorAction 0
                $firewall = Get-NetFirewallRule "FPS-SMB-In-TCP" -ErrorAction 0
                IF ($winrmserviceitem -eq $null) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRm\" -Name "Service" -Force}
                IF ($allowunencrypt -eq $null) {New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\" -Name "AllowUnencryptedTraffic" -Value 1}
                IF ($allowbasic -eq $null) {New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\WinRM\Service\" -Name "AllowBasic" -Value 1}
                IF ($firewall -ne $null) {Enable-NetFirewallRule -Name "FPS-SMB-In-TCP"}
            }
            GetScript =  { @{} }
            TestScript = { $false}
        }

        File EXCertificates
        {
            Type = 'Directory'
            DestinationPath = 'C:\EX-Certificates'
            Ensure = "Present"
        }

        File CopyEXCertFromExchange
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = "\\$EXServerIP\c$\Certificates"
            DestinationPath = "C:\EX-Certificates\"
            Credential = $Admincreds
            DependsOn = '[File]EXCertificates'
        }

        Script ConfigureWAPCertificates
        {
            SetScript =
            {
                # Create Credentials
                $Load = "$using:AdminCreds"
                $Password = $AdminCreds.Password
                                
                # Add Host Record for Resolution
                $HostFile = Get-Content "C:\Windows\System32\Drivers\Etc\Hosts"
                $Entry = $HostFile | %{$_ -match "adfs.$using:ExternalDomainName"}
                IF ($Entry -contains $False) {

                Add-Content C:\Windows\System32\Drivers\Etc\Hosts "$using:ADFSServerIP adfs.$using:ExternalDomainName"

                }

                #Check if Exchange Certificate already exists if NOT Import
                $exthumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -like "CN=owa20$using:ExchangeExistsVersion.$using:ExternalDomainName"}).Thumbprint
                IF ($exthumbprint -eq $null) {Import-PfxCertificate -FilePath "C:\EX-Certificates\owa20$using:ExchangeExistsVersion.$using:ExternalDomainName.pfx" -CertStoreLocation Cert:\LocalMachine\My -Password $Password}
            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[File]EXCertificates'
        }

        Script ConfigureWAPADFS
        {
            SetScript =
            {
                # Disable TLS 1.3
                $OS = (Get-WMIObject win32_operatingsystem).name
                IF ($OS -like '*2022*'){
                    $TLS13Key = get-item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -ErrorAction 0
                    IF ($TLS13Key -eq $null) {New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\" -Name "Client" -Force}
                    $DisabledByDefault = get-itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "DisabledByDefault" -ErrorAction 0
                    IF ($DisabledByDefault -eq $null) {New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client\" -Name "DisabledByDefault" -Value 1}
                    $Enabled = get-itemproperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client" -Name "Enabled" -ErrorAction 0
                    IF ($Enabled -eq $null) {New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.3\Client\" -Name "Enabled" -Value 0}
                }
                
                [System.Management.Automation.PSCredential ]$Creds = New-Object System.Management.Automation.PSCredential ($using:DomainCreds.UserName), $using:DomainCreds.Password

                # Get Exchange Certificate
                $exthumbprint = (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object {$_.Subject -like "CN=owa20$using:ExchangeExistsVersion.$using:ExternalDomainName"}).Thumbprint

                # Configure Publishing Rules
                $owa20WPR = Get-WebApplicationProxyApplication | Where-Object {$_.Name -like "Outlook Web App $ExchangeExistsVersion"}
                IF ($owa20WPR -eq $Null){
                    Add-WebApplicationProxyApplication -BackendServerUrl "https://owa20$using:ExchangeExistsVersion.$ExternalDomainName/owa20/" -ExternalCertificateThumbprint $exthumbprint -ExternalUrl "https://owa20$using:ExchangeExistsVersion.$ExternalDomainName/owa20/" -Name "Outlook Web App $ExchangeExistsVersion" -ExternalPreAuthentication ADFS -ADFSRelyingPartyName "Outlook Web App $ExchangeExistsVersion"
                }

                $ECPWPR = Get-WebApplicationProxyApplication | Where-Object {$_.Name -like "Exchange Admin Center (EAC) $ExchangeExistsVersion"}
                IF ($ECPWPR -eq $Null){
                    Add-WebApplicationProxyApplication -BackendServerUrl "https://owa20$using:ExchangeExistsVersion.$ExternalDomainName/ecp/" -ExternalCertificateThumbprint $exthumbprint -ExternalUrl "https://owa20$using:ExchangeExistsVersion.$ExternalDomainName/ecp/" -Name "Exchange Admin Center (EAC) $ExchangeExistsVersion" -ExternalPreAuthentication ADFS -ADFSRelyingPartyName "Exchange Admin Center (EAC) $ExchangeExistsVersion"
                }

            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[Script]ConfigureWAPCertificates'
        }
    }
  }