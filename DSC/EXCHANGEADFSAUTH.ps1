﻿configuration ADFSAUTH
{
   param
   (
        [String]$ExchangeVersion,
        [String]$ComputerName,
        [String]$InternaldomainName,
        [String]$ExternaldomainName,
        [String]$ADFSServerIP,                                                 
        [String]$NetBiosDomain,
        [System.Management.Automation.PSCredential]$Admincreds
    )

    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${NetBiosDomain}\$($Admincreds.UserName)", $Admincreds.Password)

    Node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        File CopyADFSCertsFromADFS
        {
            Ensure = "Present"
            Type = "Directory"
            Recurse = $true
            SourcePath = "\\$ADFSServerIP\c$\ADFS-Certificates"
            DestinationPath = "C:\Certificates\"
            Credential = $DomainCreds
        }

        Script ConfigureExchangeADFSCert
        {
            SetScript =
            {
                # Connect to Exchange
                $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "http://$using:computerName.$using:InternalDomainName/PowerShell/"
                Import-PSSession $Session

                $OrgConfig = Get-OrganizationConfig
                IF ($OrgConfig.AdfsIssuer -eq $Null){
                    
                    $ADFSThumbprint = Get-Content -Path C:\Certificates\ADFSSigningThumb.txt
                    
                    $uris = @("https://owa$using:ExchangeVersion.$using:ExternalDomainName/owa/","https://owa$using:ExchangeVersion.$using:ExternalDomainName/ecp/")

                    Set-OrganizationConfig -AdfsIssuer "https://adfs.$using:ExternalDomainName/adfs/ls/" -AdfsAudienceUris $uris -AdfsSignCertificateThumbprint $ADFSThumbprint
                }

                # ADFS on FORMS off
                Set-EcpVirtualDirectory -Identity "$using:computerName\ecp (Default Web Site)" -AdfsAuthentication $true -BasicAuthentication $false -DigestAuthentication $false -FormsAuthentication $false -WindowsAuthentication $false
                Set-OwaVirtualDirectory –Identity "$using:computerName\owa (Default Web Site)" -AdfsAuthentication $true -BasicAuthentication $false -DigestAuthentication $false -FormsAuthentication $false -WindowsAuthentication $false
            }
            GetScript =  { @{} }
            TestScript = { $false}
            PsDscRunAsCredential = $DomainCreds
            DependsOn = '[File]CopyADFSCertsFromADFS'
        }
    }
}