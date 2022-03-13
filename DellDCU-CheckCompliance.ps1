<#	
	.NOTES
	===========================================================================
	 Created on:   	03/13/21
	 Created by:   	Nathaniel Bannister
	 Organization: 	Command N
	 Filename:     	DellDCU-CheckCompliance.ps1
	===========================================================================
	.DESCRIPTION
		Dell Command Update - Update Compliance Check Script. Compares system to Dell's current baseline and returns counts of missing update types for external use.
#>

#Pull information about DCU install from registry:
$installedVersion = (Get-ItemProperty HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\).ProductVersion
$DCUPath = (Get-ItemProperty HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\).InstallPath
#Set working directory and name of compliance report XML:
$WorkingDirectory = "C:\Temp\"
$DCUApplicableUpdatesXML = "DCUApplicableUpdates.xml"
$DCUApplicableUpdatesXMLPath = $WorkingDirectory + $DCUApplicableUpdatesXML

#Confirm availibility of the Dell Command Update CLI
if (!(Test-Path "$DCUPath\dcu-cli.exe")) {
    Write-Host "Dell Command Update Not Installed"
    Break
} else {
    Write-Host "Dell Command | Update" $installedVersion "is installed."

    #Check for stale compliance report:
    if((Test-Path $DCUApplicableUpdatesXMLPath)){
        #Delete stale compliance report if it exists.
        Remove-Item $DCUApplicableUpdatesXMLPath -Force
    }

    #Generate the DCU Applicable Updates Report XML File:
    Start-Process "$DCUPath\dcu-cli.exe" -ArgumentList "/scan -report=$WorkingDirectory" -Wait
    $creationTime = (Get-item $DCUApplicableUpdatesXMLPath).creationtime
    $filesize = [math]::Round((Get-Item $DCUApplicableUpdatesXMLPath).length/1KB)
    Write-Host "New inventory file generated, proceeding... `n"
    Write-Host "Inventory File:" $DCUApplicableUpdatesXMLPath
    Write-Host $filesize "KB file generated @ (" $creationTime ") `n"
}

#Ingest DCU Applicable Updates Report XML File:
[xml]$XMLReport = Get-Content $DCUApplicableUpdatesXMLPath
#All Updates:
$AvailableUpdates = $XMLReport.updates.update.name.count
Write-Host "Updates Availible: " $AvailableUpdates
#BIOS Updates
$BIOSUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "BIOS" }).name.Count
Write-Host "BIOS Updates: " $BIOSUpdates
#Application Updates
$ApplicationUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Application" }).name.Count
Write-Host "Application Updates: " $ApplicationUpdates
#Driver Updates
$DriverUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Driver" }).name.Count
Write-Host "Driver Updates: " $DriverUpdates
#Firmware Updates:
$FirmwareUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Firmware" }).name.Count
Write-Host "Firmware Updates: " $FirmwareUpdates
#Other Updates:
$OtherUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Other" }).name.Count
Write-Host "Other Updates: " $OtherUpdates
#Patch Updates:
$PatchUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Patch" }).name.Count
Write-Host "Patch Updates: " $PatchUpdates
#Utility Updates
$UtilityUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Utility" }).name.Count
Write-Host "Utility Updates: " $UtilityUpdates
#Urgent Updates
$UrgentUpdates = ($XMLReport.updates.update | Where-Object { $_.Urgency -eq "Urgent" }).name.Count
Write-Host "Urgent Updates: " $UrgentUpdates    