<#	
	.NOTES
	===========================================================================
	 Created on:   	03/13/21
	 Created by:   	Nathaniel Bannister
	 Organization: 	Command N
	 Filename:     	DellDCU-Install.ps1
	===========================================================================
	.DESCRIPTION
		Dell Command Update - Install Script. Installs the current version of Dell Command Update from the web. 
#>

#Force TLS 1.2 on older systems
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Parameters
$localWorkingDir = "C:\Temp\"
$installerPath = $localWorkingDir + $FileName
#WebRequest Parameters
$DownloadURL = "https://dl.dell.com/FOLDER07820512M/1/Dell-Command-Update-Application_8DGG4_WIN_4.4.0_A00.EXE"
$FileName = "Dell-Command-Update-Application.EXE"
#Because of Dell's CDN we now have to provide a user agent or requests will get denied with a 403.
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36";

#Make sure the script is running from an elevated PowerShell session
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )
If($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
{
	Write-Host "This is an elevated PowerShell session"
}
Else
{
	Write-Host "$(Get-Date): This is NOT an elevated PowerShell session. Script will exit."
	Exit
}

#Create working directory if it doesn't exist:
Write-Host "Creating Working Directory if it doesn't exist already ($localWorkingDir):"
if(!(Test-Path C:\Temp)){New-Item -Path "c:\" -Name "Temp" -ItemType "directory"}

#Install DSU if it's not installed, upgrade it if it is:
Write-Host "Installing Dell Command Update ... "
Invoke-WebRequest -Uri $DownloadURL -OutFile "$localWorkingDir$DCUInstaller" -UserAgent $UserAgent
Write-Host "Starting Instllation:" $DCUInstallerPath
Start-Process -FilePath $installerPath -ArgumentList "/s" -Wait
Write-Host "Installation Complete."