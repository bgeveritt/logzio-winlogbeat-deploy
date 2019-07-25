# logzio-winlogbeat-deploy

This PowerShell script allows you to deploy Winlogbeat on one or multiple Windows hosts, automatically applying your Logz.io settings.

#### Requirements:

* Windows (64-bit)
* PowerShell 5.1
* Ensure the appropriate Execution Policy is set on the machine (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-5.1)

#### Notes:

* Default values are supplied in the script; to change any that are specific to your environment, edit `InstallLogzioWinlogbeat.ps1` and update the values under the section that reads `#DEFAULT VALUES; REPLACE ONLY IF NEEDED`
* The current release of this script installs Winlogbeat v7.2.0
* The current release of this script only works on Windows instances that have no previous installation of Winlogbeat
* The current release of this script supports Application, System, and Security events

#### Instructions:

* Download `InstallLogzioWinlogbeat.ps1`
* Open a PowerShell session via `Run as administrator`
* Execute `InstallLogzioWinlogbeat.ps1` and provide your Logz.io token and listener address. Example:

  `.\InstallLogzioWinlogbeat.ps1 -token QieuWHajIABErtkatjavfdjNhu -listener listener.logz.io:5015`
 
* The script will download Winlogbeat, the Logz.io certificate, apply the necessary configuration to your `winlogbeat.yml`, install it as a service, and start it. Pending a successful completion, you should see logs surfacing within seconds.
* To deploy across multiple Windows machines, a third-party orchestration tool (e.g.: Ansible, Chef, Puppet, etc.) will be necessary.

