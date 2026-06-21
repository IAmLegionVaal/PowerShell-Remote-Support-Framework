[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
param(
 [string[]]$ComputerName=@($env:COMPUTERNAME),
 [ValidateSet('FlushDns','RestartService','GpUpdate','SfcScan','DismRestoreHealth','RestartSpooler')][string]$Action,
 [string]$ServiceName,
 [switch]$DryRun,[switch]$Yes,
 [string]$OutputPath=(Join-Path $env:ProgramData 'RemoteSupportRepair')
)
$ErrorActionPreference='Stop';$script:Failures=0
$run=Join-Path $OutputPath (Get-Date -Format yyyyMMdd_HHmmss);New-Item -ItemType Directory $run -Force|Out-Null
$log=Join-Path $run 'repair.log';$results=Join-Path $run 'results.json'
function Log($m){"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"|Tee-Object -FilePath $log -Append}
if(-not $Action){Write-Error '-Action is required.';exit 2}
if($Action -eq 'RestartService' -and -not $ServiceName){Write-Error '-ServiceName is required.';exit 2}
if(-not $Yes -and -not $DryRun){if((Read-Host "Run $Action on $($ComputerName -join ', ')? Type YES") -ne 'YES'){Log 'Cancelled.';exit 10}}
$scriptBlock={param($SelectedAction,$SelectedService,$Preview)
 $state=[ordered]@{ComputerName=$env:COMPUTERNAME;Collected=Get-Date;Action=$SelectedAction;Success=$false;Message=''}
 if($Preview){$state.Success=$true;$state.Message='Dry run only';return [pscustomobject]$state}
 try{
  switch($SelectedAction){
   'FlushDns'{Clear-DnsClientCache}
   'RestartService'{Restart-Service -Name $SelectedService -Force -ErrorAction Stop}
   'GpUpdate'{$p=Start-Process gpupdate.exe -ArgumentList '/force' -Wait -PassThru -NoNewWindow;if($p.ExitCode){throw "gpupdate exited $($p.ExitCode)"}}
   'SfcScan'{$p=Start-Process sfc.exe -ArgumentList '/scannow' -Wait -PassThru -NoNewWindow;if($p.ExitCode -notin 0,1){throw "SFC exited $($p.ExitCode)"}}
   'DismRestoreHealth'{$p=Start-Process dism.exe -ArgumentList '/Online','/Cleanup-Image','/RestoreHealth' -Wait -PassThru -NoNewWindow;if($p.ExitCode){throw "DISM exited $($p.ExitCode)"}}
   'RestartSpooler'{Restart-Service Spooler -Force -ErrorAction Stop}
  }
  $state.Success=$true;$state.Message='Completed'
 }catch{$state.Message=$_.Exception.Message}
 [pscustomobject]$state
}
$all=@()
foreach($computer in $ComputerName){
 Log "Starting $Action on $computer"
 try{
  if($computer -in @($env:COMPUTERNAME,'localhost','.')){$r=& $scriptBlock $Action $ServiceName $DryRun}
  else{$r=Invoke-Command -ComputerName $computer -ScriptBlock $scriptBlock -ArgumentList $Action,$ServiceName,[bool]$DryRun -ErrorAction Stop}
  $all+=$r;if(-not $r.Success){$script:Failures++};Log "$computer result: $($r.Message)"
 }catch{$script:Failures++;$all+=[pscustomobject]@{ComputerName=$computer;Collected=Get-Date;Action=$Action;Success=$false;Message=$_.Exception.Message};Log "$computer failed: $($_.Exception.Message)"}
}
$all|ConvertTo-Json -Depth 4|Set-Content $results -Encoding UTF8
$all|Export-Csv (Join-Path $run 'results.csv') -NoTypeInformation
if($script:Failures){exit 20};exit 0
