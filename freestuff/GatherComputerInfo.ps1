################################################################################
#
# GatherComputerInfo
# ==================
# 
# This is a powershell script that could be set up on a desktop computer
# to run when the computer starts, or at any time really. It gathers some
# information about the computer and formats it into a REBOL-readable 
# file, and stores that file for use by reporting programs.             
#  
# The plan is to keep this script in a central location (a network drive)
# and have every computer run it at startup.  The script assembles relevant
# information and writes it to a text file in a central location.
# The text file has a name based on the computer name of the computer
# running the script.  Other programs can assemble all those individual
# text files and report on them in as-yet undefined ways.
#
################################################################################

## Miscellaneous items to reuse.
$Q = '"'  ## Double quote for building strings compatible elsewhere.

## Function from the internet, adapted, to get ip address and mac address.
function Get-MyMACAddress {
    $colItems = get-wmiobject -class "Win32_NetworkAdapterConfiguration" | Where{$_.IpEnabled -Match "True"} 
        foreach ($objItem in $colItems) { 
            $objItem |select Description,MACAddress,IPAddress,DefaultIPGateway,IPSubnet
	}
}
$NETWORKDATA = Get-MyMACAddress

## Function from the internet to get the path to the default browser
Function GET-DefaultBrowserPath {
    #Get the default Browser path
    New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root | Out-Null
    $browserPath = ((Get-ItemProperty 'HKCR:\http\shell\open\command').'(default)').Split('"')[1]      
    return $browserPath
}
$DEFAULTBROWSER = GET-DefaultBrowserPath

## Function from the internet to get monitor information
$MONITORLIST = ""
Function Get-MonitorInfo
{
    [CmdletBinding()]
    Param
    (
        [Parameter(
        Position=0,
        ValueFromPipeLine=$true,
        ValueFromPipeLineByPropertyName=$true)]
        [string]$name = '.'
    )
    Process
    {
        $ActiveMonitors = Get-WmiObject -Namespace root\wmi -Class wmiMonitorID -ComputerName $name
        $monitorInfo = @()
        foreach ($monitor in $ActiveMonitors)
        {
            $mon = New-Object PSObject
            $manufacturer = $null
            $product = $null
            $serial = $null
            $name = $null
            $week = $null
            $year = $null

            $monitor.ManufacturerName | foreach {$manufacturer += [char]$_}
            $monitor.ProductCodeID | foreach {$product += [char]$_}
            $monitor.SerialNumberID | foreach {$serial += [char]$_}
            $monitor.UserFriendlyName | foreach {$name += [char]$_}

            $BLOCK = $Q+$serial+$Q+" "+$Q+$manufacturer+$Q+" "+$monitor.YearOfManufacture+" " 
            $script:MONITORLIST = $script:MONITORLIST+$BLOCK
        }
    }
}
$MONITORLIST = "MONITORS: [" 
Get-Monitorinfo 
$MONITORLIST = $MONITORLIST+"]"  

# Get the name of the computer, and use it to put together the name of the
# file that we will write to a central location.

$MYNAME = Get-Content env:COMPUTERNAME
$FILENAME = "I:\temp\"+$MYNAME+".txt"  ## Modify this for your installation.

# Assemble all the data items we want to report.

$USERNAME = Get-Content env:USERNAME
$LOGINDATE = Get-Date -uformat %Y/%m/%d
$LOGINTIME = Get-Date -uformat %H:%M
$computerSystem = get-wmiobject Win32_ComputerSystem
$computerBIOS = get-wmiobject Win32_BIOS
$computerOS = get-wmiobject Win32_OperatingSystem
$COMPUTERNAME = $computerSystem.Name
$MANUFACTURER = $computerSystem.Manufacturer
$MODEL = $computerSystem.Model
$SERIALNO = $computerBIOS.SerialNumber
$LOGGEDIN = $computerSystem.UserName
$OS = $computerOS.caption
$MEMORY = $computerSystem.TotalPhysicalMemory/1GB
$LASTREBOOT = $computerOS.ConvertToDateTime($computerOS.LastBootUpTime)
$IPADDRESS = $NETWORKDATA.IPAddress
$MACADDRESS = $NETWORKDATA.MACAddress
$IEVERSION = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Internet Explorer').version 

# Write our assembled data to the central location.
# Remove the previous file first, if present. 

if (Test-Path $FILENAME)
{
    Remove-Item $FILENAME
}
Add-Content $FILENAME -value "USERNAME: ""$USERNAME"""
Add-Content $FILENAME -value "LOGINDATE: ""$LOGINDATE"""
Add-Content $FILENAME -value "LOGINTIME: ""$LOGINTIME"""
Add-Content $FILENAME -value "COMPUTERNAME: ""$COMPUTERNAME"""  
Add-Content $FILENAME -value "MANUFACTURER: ""$MANUFACTURER""" 
Add-Content $FILENAME -value "MODEL: ""$MODEL"""
Add-Content $FILENAME -value "SERIALNO: ""$SERIALNO""" 
Add-Content $FILENAME -value "LOGGEDIN: ""$LOGGEDIN""" 
Add-Content $FILENAME -value "OS: ""$OS""" 
Add-Content $FILENAME -value "MEMORY: ""$MEMORY""" 
Add-Content $FILENAME -value "LASTREBOOT: ""$LASTREBOOT""" 
Add-Content $FILENAME -value "IPADDRESS: ""$IPADDRESS""" 
Add-Content $FILENAME -value "MACADDRESS: ""$MACADDRESS""" 
Add-Content $FILENAME -value "IEVERSION: ""$IEVERSION"""
Add-Content $FILENAME -value "DEFAULTBROWSER: ""$DEFAULTBROWSER"""
Add-Content $FILENAME -value $MONITORLIST 

# Now try an idea harvested from the internet.
# Use the registry "uninstall keys" to identify installed software.
# Write the results to our text file in a REBOL-compatible format.

add-content $FILENAME -value "INSTALLED-SOFTWARE: ["

# Make an array object to hold what we find.
$array = @()

# Define the variable to hold the location of Currently Installed Programs
$UninstallKey="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 

# Create an instance of the Registry Object and open the HKLM base key
$reg=[microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$MYNAME) 

# Drill down into the Uninstall key using the OpenSubKey Method
$regkey=$reg.OpenSubKey($UninstallKey) 

# Retrieve an array of string that contain all the subkey names
$subkeys=$regkey.GetSubKeyNames() 

# Open each Subkey and use GetValue Method to return the required values for each.
# Append those values to our array object. 
foreach($key in $subkeys){
    $thisKey=$UninstallKey+"\\"+$key 
    $thisSubKey=$reg.OpenSubKey($thisKey) 
    $obj = New-Object PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $($thisSubKey.GetValue("DisplayName"))
    $obj | Add-Member -MemberType NoteProperty -Name "DisplayVersion" -Value $($thisSubKey.GetValue("DisplayVersion"))
    $array += $obj
} 

# Go through the array object we built and write it to the output file.
foreach($ITEM in $array) {
    if ($ITEM.Displayname) {
        $outname = $ITEM.Displayname
        $outversion = $ITEM.DisplayVersion
        $outline = '"'+$ITEM.Displayname+'" "'+$ITEM.DisplayVersion+'"'
        add-content $FILENAME -value $outline
    }
}
Add-Content $FILENAME -value "]"

# Note:  The operation of finding installed software doesn't always work,
# so it seems.  It crashes somewhere and the above square bracket does
# not get added, and the REBOL program that reads this file then
# crashes.  So, make a note, the above square bracket must be the
# last character in the file.  Other programs will check for its
# existence to make sure that the file is complete.


