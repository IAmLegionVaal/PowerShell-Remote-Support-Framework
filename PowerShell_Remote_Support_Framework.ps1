#requires -Version 5.1
<#
.SYNOPSIS
    PowerShell Remote Support Framework.
.DESCRIPTION
    Reusable safe framework pattern for IT support scripts.
#>
[CmdletBinding()]
param([string]$OutputPath)
$RunStamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Remote_Support_Framework_Reports'}
New-Item -Path $OutputPath -ItemType Directory -Force|Out-Null
$LogFile=Join-Path $OutputPath "framework_$RunStamp.log"
function Test-IsAdmin{$p=New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent());$p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)}
function Write-Log{param([string]$Message,[string]$Level='INFO')$line='{0} [{1}] {2}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),$Level,$Message;Add-Content $LogFile $line -Encoding UTF8;Write-Host $Message}
function Confirm-SafeAction{param([string]$Message)$answer=Read-Host "$Message Type YES to continue";$answer -eq 'YES'}
function Export-Data{param($Name,$Data)$Data|Export-Csv (Join-Path $OutputPath "$Name.csv") -NoTypeInformation -Encoding UTF8;$Data|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "$Name.json") -Encoding UTF8}
function New-Check{param($Area,$Name,$Status,$Value,$Recommendation)[PSCustomObject]@{Area=$Area;Name=$Name;Status=$Status;Value=$Value;Recommendation=$Recommendation}}
function Invoke-SampleDiagnostic{$os=Get-CimInstance Win32_OperatingSystem;$check=New-Check 'System' 'OS context' 'Info' "$($os.Caption) Build $($os.BuildNumber)" 'Replace this with tool-specific checks.';Export-Data "sample_diagnostic_$RunStamp" @($check);$check|Format-Table -AutoSize}
Write-Log "Framework started. Admin=$(Test-IsAdmin)"
do{Clear-Host;Write-Host 'PowerShell Remote Support Framework' -ForegroundColor Cyan;Write-Host '1. Run sample diagnostic';Write-Host '2. Open report folder';Write-Host '0. Exit';$choice=Read-Host 'Choose';switch($choice){'1'{Invoke-SampleDiagnostic;Read-Host 'Enter to continue'}'2'{Start-Process explorer.exe -ArgumentList "`"$OutputPath`""}}}while($choice -ne '0')
Write-Log 'Framework closed.'
