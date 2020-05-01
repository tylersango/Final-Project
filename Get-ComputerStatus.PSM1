function Get-ComputerStatus {
#Tyler Sango
#April 2nd
#Project 1 - Get computer info script that can run on remote machines

#Step 1: Determine Operating System information. Output only the OS name, build and version number.
    [CmdletBinding ()]
    param (
        [Parameter(Mandatory=$True)]
        [String[]] $ComputerName
    )
    begin {}
        Process{
               foreach ($Computer in $ComputerName) {
            $D = Get-Date -Format "MM-dd-yyyy"
            $OutPutFile = "C:\$Computer-$D.txt"

                Write-Output "System info report" | Out-File $OutPutFile

#Step 1: Determine operating system information. Output only the OS name, build and version number.

                Write-Output "Operating System Information" | Out-File $OutPutFile -Append

                Get-CimInstance win32_operatingsystem -ComputerName $Computer | 
                Select-Object Name, BuildNumber, Version | 
                Out-File $OutPutFile -Append

#Step 2: Processor information. Output only the DeviceID, the name and the max clock.

                Write-Output "Machine Processor Information" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_Processor -ComputerName $Computer |
                Select-Object DeviceID,Name,MaxClockSpeed |
                Out-File $OutPutFile -Append

#Step 3: Determine IP Address Configuration. Output only the IP Address, Subnet Mask, Default Gateway, and whether the system uses DHCP.

                Write-Output "Network Configuration" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_NetworkAdapterConfiguration -ComputerName $Computer |
                Select-Object -Property IPAddress,IpSubnet,DefaultIPGateway,DHCPEnabled |
                Out-File $OutPutFile -Append

#Step 4: Acquire DNS client server address. Output only the DNS Server IP Address.

                Write-Output "DNS Client Information" | Out-File $OutPutFile -Append

                Get-DnsClientServerAddress -InterfaceAlias Ethernet0 -CimSession $Computer | 
                Select-Object -Property ServerAddresses |
                Out-File $OutPutFile -Append

#Step 5: Determine the amount of system memory in GB. Output only the amount of memory.
    #I chose this method over using a measure object output because I noticed my virtual machine has two different sized ram installed.

                Write-Output "System Memory Installed" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_PhysicalMemory -ComputerName $Computer | 
                Select-Object @{N="System Memory (GB)";E={$_.Capacity/1GB}} |
                Out-File $OutPutFile -Append

#Step 6: Determine the amount of free space (In GB) for the  drive. Output only the amount of free space.

                Write-Output "Disk free space in C: drive" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_LogicalDisk -ComputerName $Computer |
                Where-Object DeviceID -EQ C: |
                Select-Object @{N="Available System Storage (GB)";E={$_.FreeSpace/1GB}} |
                Out-File $OutPutFile -Append

#Step 7: Determine last bootup date/time. Output the computers name and the last boot time.

                Write-Output "Last boot up date and time" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_OperatingSystem -ComputerName $Computer | 
                Select-Object CSName,LastBootUpTime |
                Out-File $OutPutFile -Append

#Step 8: Determine last user login date and time. Output the users name and the last logon date/time.

                Write-Output "Last user login date and time" | Out-File $OutPutFile -Append

                Invoke-Command {Get-LocalUser} -ComputerName $Computer |
                Select-Object Name,LastLogon |
                Out-File $OutPutFile -Append

#Step 9: Retrieve all user accounts on the system. Output only the account names

                Write-Output "All accounts on system" | Out-File $OutPutFile -Append

                Invoke-Command {Get-LocalUser} -ComputerName $Computer |
                Select-Object Name |
                Out-File $OutPutFile -Append

#Step 10: Determine installed hotfixes and updates. Output only the hotfix ID.

                Write-Output "Hotfixes performed" | Out-File $OutPutFile -Append

                Invoke-Command {Get-HotFix} -ComputerName $Computer |
                Select-Object HotFixID |
                Out-File $OutPutFile -Append

#Step 11: List all installed applications. Output only the application name, vendor, and version. 

                Write-Output "List of installed applications" | Out-File $OutPutFile -Append

                Get-CimInstance Win32_Product -ComputerName $Computer |
                Select-Object Name,Vendor,Version |
                Out-File $OutPutFile -Append
            }#For Each
        }#Process
    end {}
}