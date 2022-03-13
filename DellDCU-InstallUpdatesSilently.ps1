<#  
    .NOTES
    ===========================================================================
     Created on:    03/13/21
     Created by:    Nathaniel Bannister
     Organization:  Command N
     Filename:      DellDCU-InstallUpdatesSilently.ps1
    ===========================================================================
    .DESCRIPTION
         Dell Command Update - Update Install Script. Install all updates currently out of compliance with Dell's baseline.
#>

#Pull information about DCU install from registry:
$DCUPath = (Get-ItemProperty HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\).InstallPath
$installedVersion = (Get-ItemProperty HKLM:\SOFTWARE\Dell\UpdateService\Clients\CommandUpdate\Preferences\Settings\).ProductVersion
#Configure automatic restarts after patching:
[datetime]$RestartTime = "12:00AM"
[datetime]$CurrentTime = Get-Date
[int]$WaitSeconds = ( $RestartTime - $CurrentTime ).TotalSeconds

if (!(Test-Path "$DCUPath\dcu-cli.exe")) {
    Write-Host "Dell Command Update Not Installed"
    Break
} else {
        Write-Host "$software $installedVersion is installed."

        #Set working directory and name of update log:
        $WorkingDirectory = "C:\Temp\"
        $logFile = "DCU-Update-Log.log"
        $logFilePath = $WorkingDirectory + $logFile
        
        #Use the DCU CLI to install all applicable updates
        Write-Host "Starting Dell Command Update ... "
        Start-Process 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe' -ArgumentList "/scan" -Wait
        $applyUpdates = Start-Process 'C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe' -ArgumentList "/applyUpdates -outputLog=$logFilePath -autoSuspendBitLocker=enable -reboot=false" -PassThru -Wait
        Write-Host "Command Update exited with Exit Code: " $applyUpdates.ExitCode
        Write-Host "Please reboot ASAP or system will restart automatically at: " $RestartTime "or in approximately " $WaitSeconds " seconds!"
        shutdown -r -t $WaitSeconds
}

<#
Some thoughts on future improvements:
* Use the $applyUpdates variable to interpret exit codes: https://www.dell.com/support/manuals/en-ec/command-update/dellcommandupdate_rg/command-line-interface-error-codes?guid=guid-fbb96b06-4603-423a-baec-cbf5963d8948&lang=en-us
* Use some of the additional parameters (https://www.dell.com/support/manuals/en-ec/command-update/dellcommandupdate_rg/dell-command-%7C-update-cli-commands?guid=guid-92619086-5f7c-4a05-bce2-0d560c15e8ed&lang=en-us):
    * updateSeverity - Limit to updates of a certain severity
    * updateType - Limit to updates of a certain type
    * scheduleX - Set a user defined update schedule outside the scope of this script
#>