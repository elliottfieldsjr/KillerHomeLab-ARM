@{
    moduleVersion        = '1.16.1'

    GUID                 = '026e7fd8-06dd-41bc-b373-59366ab18679'

    Author               = 'DSC Community'

    CompanyName          = 'DSC Community'

    Copyright            = 'Copyright the DSC Community contributors. All rights reserved.'

    Description          = 'Module containing DSC resources for deployment and configuration of Windows Server Failover Cluster.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '4.0'

    # Functions to export from this module
    FunctionsToExport    = @()

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    DscResourcesToExport = @('xCluster','xClusterDisk','xClusterNetwork','xClusterPreferredOwner','xClusterProperty','xClusterQuorum','xWaitForCluster')

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Set to a prerelease string value if the release should be a prerelease.
            Prerelease   = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/xFailOverCluster/blob/main/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/xFailOverCluster'

            # A URL to an icon representing this module.
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # ReleaseNotes of this module
            ReleaseNotes = '## [1.16.1] - 2022-05-24

### Deprecated

- **The module _xFailOverCluster_ will be renamed to _FailoverClusterDsc_ ([issue #69](https://github.com/dsccommunity/xFailOverCluster/issues/69)).
  The version `v1.6.1` will be the the last release of _xFailOverCluster_.
  The Version `v2.0.0` will be released as _FailoverClusterDsc_, it will be
  released shortly after the `v1.6.1` release to be able to start transition
  to the new module. The prefix ''x'' will be removed from all resources in
  _FailoverClusterDsc_.**

'
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
