function Get-ComputerStatus {
    #Tyler Sango
    #April 2nd
    #Project 1 - Get computer info script that can run on remote machines
    
        [CmdletBinding ()]
        param (
            [Parameter(Mandatory=$True)]
            [String[]] $ComputerName
        )
        begin {}
            Process{
                   foreach ($Computer in $ComputerName) {
    
    #Step 1: IP Address for a remote system and whether the system uses DHCP (Two properties)
    
                $IP=Get-CimInstance Win32_NetworkAdapterConfiguration -ComputerName $Computer | `
                    Select-Object -Property IPAddress,DHCPEnabled
    
    #Step 2: Acquire DNS Client Server address used by remote system (One Property)
    
                $DNS=Get-DnsClientServerAddress -InterfaceAlias Ethernet0 -CimSession $Computer | `
                    Select-Object -Property ServerAddresses
    
    #Step 3: Determine Operating System name, build and version number of remote system (Three Properties)
    
                $OS=Get-CimInstance win32_operatingsystem -ComputerName $Computer | `
                    Select-Object Name, BuildNumber, Version
            
    #Step 4: Determine the amount of system memory in GB (One Property)
    
                $RAM=Get-CimInstance Win32_PhysicalMemory -ComputerName $Computer | `
                    Select-Object @{N="System Memory (GB)";E={$_.Capacity/1GB}}
    
    #Step 5: Processor Name for remote system (One Property)
    
                $CPU=Get-CimInstance Win32_Processor -ComputerName $Computer | `
                    Select-Object Name
            
    #Step 6: Determine the amount of free space (In GB) for the  drive on the remote system (One Property)
    
                $HDD=Get-CimInstance Win32_LogicalDisk -ComputerName $Computer | `
                    Where-Object DeviceID -EQ C: | `
                    Select-Object @{N="Available System Storage (GB)";E={$_.FreeSpace/1GB}}
            
    
    #Step 7: Determine the last reboot performed by a remote system
    
                $REBOOT=Get-CimInstance Win32_OperatingSystem -ComputerName $Computer | `
                    Select-Object CSName,LastBootUpTime
    
                }#For Each
            }#Process
        end {}
    }