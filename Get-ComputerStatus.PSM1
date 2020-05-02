function Get-ComputerStatus {
    #Tyler Sango
    #May 1st 2020
    #Final Project - Get remote computer status

        [CmdletBinding ()]
        param (
            [Parameter(Mandatory=$True)]
            [String[]] $ComputerName
        )
        begin {}
            Process{
                   foreach ($Computer in $ComputerName) {
    #Using Sessions: Step 4
                    New-PSSession -ComputerName $Computer
                    $PS1 = Get-PSSession
Invoke-Command -Session $PS1 -ScriptBlock{
    #Step 1: IP Address for a remote system and whether the system uses DHCP (Two properties)
    
                $IP=Get-CimInstance Win32_NetworkAdapterConfiguration
    
    #Step 2: Acquire DNS Client Server address used by remote system (One Property)
    
                $DNS=Get-DnsClientServerAddress -InterfaceAlias Ethernet0
    
    #Step 3: Determine Operating System name, build and version number of remote system (Three Properties)
    
                $OS=Get-CimInstance win32_operatingsystem
            
    #Step 4: Determine the amount of system memory in GB (One Property)
    
                $RAM=Get-CimInstance Win32_PhysicalMemory | `
                    Select-Object @{N="System Memory (GB)";E={$_.Capacity/1GB}}
    
    #Step 5: Processor Name for remote system (One Property)
    
                $CPU=Get-CimInstance Win32_Processor
            
    #Step 6: Determine the amount of free space (In GB) for the  drive on the remote system (One Property)
    
                $HDD=Get-CimInstance Win32_LogicalDisk | `
                    Where-Object DeviceID -EQ C:
            
    
    #Step 7: Determine the last reboot performed by a remote system
    
                $REBOOT=
                    Get-CimInstance Win32_OperatingSystem

                        $props = @{
                            'RemoteIPAddress'=$IP.IPAddress;
                            'RemoteUsesDHCP'=$IP.DHCPEnabled;
                            'RemoteDNSClientServerAddress'=$DNS.ServerAddresses;
                            'RemoteOSName'=$OS.Name;
                            'RemoteOSBuildNumber'=$OS.BuildNumber;
                            'RemoteOSVersion'=$OS.Version;
                            'RemoteMemoryInGB'=$RAM."System Memory (GB)";
                            'RemoteProcessorName'=$CPU.Name;
                            'RemoteFreeSpace'=$HDD.FreeSpace/1GB;
                            'RemoteLastReboot'=$REBOOT.LastBootUpTime
                                  }
                    $Obj = New-Object -TypeName PSObject -Property $props
                                
            Write-Output $Obj
                                } | Select-Object -Property * -ExcludeProperty PSComputerName,RunSpaceID
Remove-PSSession $PS1
                                
                }#For Each
            }#Process
        end {}
    }