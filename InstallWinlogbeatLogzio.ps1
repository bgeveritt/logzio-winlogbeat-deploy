#ENTER YOUR LOGZ.IO TOKEN AND LISTENER ADDRESS
$logzioToken = '' #Example: QwErTyuiaCnahEjaiIVBFkjkniy
$logzioListener = '' #Example: listener.logz.io:5015

#DEFAULT VALUES; REPLACE ONLY IF NEEDED
$wlbVersion = '7.2.0'
$tempFolder = 'C:/Windows/Temp/'
$wlbHome = 'C:/Program Files/Winlogbeat/'
$wlbUrl = ('https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-{0}-windows-x86_64.zip' -f $wlbVersion)

#CONSTANT VALUES; DO NOT CHANGE!!!
$constLogzioCertificate = 'https://raw.githubusercontent.com/logzio/public-certificates/master/COMODORSADomainValidationSecureServerCA.crt'
$constWlbYamlUrl = 'https://github.com/bgeveritt/logzio-winlogbeat-deploy/blob/master/winlogbeat.yml'
$constWlbSvcInstallerFilename = 'install-service-winlogbeat.ps1'
$constWlbSvc = 'winlogbeat'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Download Winlogbeat (v7.2.0)
Write-Host ('Downloading Winlogbeat version {0}...' -f $wlbVersion)
$filename = Split-Path $wlbUrl -Leaf
$outpath = ('{0}{1}' -f $tempFolder, $filename)
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($wlbUrl, $outpath)

#Expand archive and create $wlbHome
while (!(Test-Path $outpath)) { Start-Sleep -s 3 }
Write-Host 'Expanding Winlogbeat...'
Expand-Archive -LiteralPath $outpath -DestinationPath $tempFolder
New-Item -Path $wlbHome -ItemType "Directory"

#Copy expanded files to $wlbHome
$wlbExpanded = ('{0}{1}' -f $tempFolder, (Get-Item $outpath).Basename)
Write-Host ('Copying Winlogbeat to {0}...' -f $wlbHome)
while (!(Test-Path $wlbExpanded)) { Start-Sleep -s 3 }
Copy-Item ('{0}\*' -f $wlbExpanded) -Destination $wlbHome -Recurse

#Download Logz.io certificate
while (!(Test-Path $wlbHome)) { Start-Sleep -s 3 }
Write-Host ('Downloading Logzio certificate and saving to {0}...' -f $wlbHome)
$wc.DownloadFile($constLogzioCertificate, ('{0}{1}' -f $wlbHome, (Split-Path $constLogzioCertificate -Leaf)))

#Delete old winlogbeat.yml
$wlbYaml = ('{0}{1}' -f $wlbHome, (Split-Path $constWlbYamlUrl -Leaf))
while (!(Test-Path $wlbYaml)) { Start-Sleep -s 3 }
Remove-Item $wlbYaml

#Download Logz.io Winlogbeat configuration file
Invoke-WebRequest -Uri $constWlbYamlUrl -OutFile ('{0}{1}' -f $wlbHome, (Split-Path $constWlbYamlUrl -Leaf))

#Replace Logz.io Winlogbeat configuration file with specific values
while (!(Test-Path $wlbYaml)) { Start-Sleep -s 3 }
Write-Host 'Updating winlogbeat.yml with Logz.io token, listener address, and certificate filepath...'
((Get-Content -Path $wlbYaml -Raw) -Replace '<<LOGZ.IO TOKEN>>', $logzioToken -Replace '<<LOGZ.IO LISTENER>>', $logzioListener -Replace '<<LOGZ.IO CERTIFICATE>>', ('{0}{1}' -f $wlbHome, (Split-Path $constLogzioCertificate -Leaf))) | Set-Content -Path $wlbYaml

#Install Winlogbeat service and start it
Write-Host 'Installing and starting winlogbeat service...'
$constWlbSvcInstall = ('{0}{1}' -f $wlbHome, $constWlbSvcInstallerFilename)
Invoke-Expression "& '$constWlbSvcInstall'"
$startWinlogbeatService = Get-Service -Name $constWlbSvc
while ($startWinlogbeatService.Status -ne 'Running')
{
    Start-Service $constWlbSvc
    Start-Sleep -s 3
    $startWinlogbeatService.Refresh()
}

#Clean up temp directory
Write-Host 'Cleaning up temporary files...'
Remove-Item $outpath
Remove-Item $wlbExpanded -Recurse

Write-Host 'Completed'
