# Deploy SCEP with Intune Infrastructure
<img src="./x_Images/SCEPwithIntuneInfra.svg" height="600" width="800"/>

THE FOLLOWING DEPLOYMENT MUST ALREADY EXIST IN ORDER TO USE THIS DEPLOYMENT:

- Deploy-PKI-Enterprise-CA-With-OCSP (PKIDeploymentType = Enterprise-PKI)

**** THE PARAMETERS SPECIFIED FOR THIS ADD-ON LAB MUST MATCH THE PARAMETERS OF THE BASE LAB THAT IT WILL BE ADDED TO ****

This Deployment deploys the following items:

- 1 - Network Device Enrollment Service Server
- 1 - Azure KeyVault with Secret contianing Deployment Password

The deployment leverages Desired State Configuration scripts to further customize the following:

- Create NDES Service Account
- Configure Internal DNS NDES Record
- Configure Network Device Enrollment Service


All Virtual Machines can be accessed via the [Bastion Host](https://docs.microsoft.com/en-us/azure/bastion/bastion-overview) that was deployed by using the Username and Password provided during depoyment.  The password can be manually entered or retrieved from the KeyVault that is creatd during deployment.

If you can't remember the Password used during deployment it is also written to an Encrypted Secret within the deployed KeyVault and can be retrieved as shown below:

<img src="./x_Images/DeploymentPassword.png" width="600"/>

If you can't remember the Username review the Deployment Input tab within your Resources Groups Deployment
<img src="./x_Images/DeploymentUsername.png" width="300"/>

This Deployment creates an Azure Public DNS Zone that is capable of providing resolution to external clients.  To use this capability the Name Servers defined within the Azure Public DNS Zone must be notated and used as the External Name Servers of your Name Registrar.  In order to locate these Name Servers navigate to the Azure Public DNS Zone as shown below:

<img src="./x_Images/NameServers.png"/>

Parameters that support changes
- TimeZone.  Select an appropriate Time Zone.
- AutoShutdownEnabled.  Yes = AutoShutdown Enabled, No = AutoShutdown Disabled.
- AutoShutdownTime.  24-Hour Clock Time for Auto-Shutdown (Example: 1900 = 7PM)
- AutoShutdownEmail.  Auto-Shutdown notification Email (Example:  user@domain.com)
- CertificateConnectorEXEURL.  Download URL for Certificate Conenctor Install.
- NDESServiceAccount.  Service Account for Windows NDES Service
- Admin Username.  Enter a valid Admin Username
- Admin Password.  Enter a valid Admin Password
- Azure UserObject ID.  Object ID for the Azure Using running the deployment
- WindowsServerLicenseType.  Choose Windows Server License Type (Example:  Windows_Server or None)
- Naming Convention. Enter a name that will be used as a naming prefix for (Servers, VNets, etc) you are using.
- Sub DNS Domain.  OPTIONALLY, enter a valid DNS Sub Domain. (Example:  sub1. or sub1.sub2.    This entry must end with a DOT )
- Sub DNS BaseDN.  OPTIONALLY, enter a valid DNS Sub Base DN. (Example:  DC=sub1, or DC=sub1,DC=sub2,    This entry must end with a COMMA )
- Net Bios Domain.  Enter a valid Net Bios Domain Name (Example:  killerhomelab).
- Internal Domain.  Enter a valid Internal Domain (Exmaple:  killerhomelab)
- InternalTLD.  Select a valid Top-Level Domain using the Pull-Down Menu.
- External Domain. Enter a valid External Domain (Example: sub1.killerhomelab.  Remove sub1. if you do not want a subdomain for the External domain
- ExternalTLD. Select a valid Top-Level Domain for your External Domain using the Pull-Down Menu.
- Vnet1ID.  Enter first 2 octets of your desired Address Space for Virtual Network 1 (Example:  10.1)
- Enterprise CA Name. Enter a Name for your Enterprise Certificate Authority
- NDESOSSku.  Select 2022-Datacenter (Windows 2022), 2019-Datacenter (Windows 2019), 2016-Datacenter (Windows 2016) or 2012-R2-Datacenter (Windows 2012 R2) NDES OS Sku
- NDESOSVersion.  The default is Latest however a specific OS Version can be entired based on the above OS Sku.
- NDESVMSize.  Enter a Valid VM Size based on which Region the VM is deployed.