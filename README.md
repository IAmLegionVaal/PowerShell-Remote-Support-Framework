# PowerShell Remote Support Framework

A reusable PowerShell framework for diagnostic and repair workflows on local or authorised remote Windows computers.

## Framework example

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\PowerShell_Remote_Support_Framework.ps1
```

## Remote repair runner

Preview an action:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01 -Action FlushDns -DryRun
```

Examples:

```powershell
.\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01,PC02 -Action FlushDns
.\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01 -Action RestartService -ServiceName Spooler
.\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01 -Action GpUpdate
.\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01 -Action SfcScan
.\Invoke_Remote_Support_Repair.ps1 -ComputerName PC01 -Action DismRestoreHealth
```

## What the repair runner does

- Runs one explicitly selected support action locally or through PowerShell remoting.
- Supports DNS cache flushing, selected-service restart, Group Policy refresh, SFC, DISM and Print Spooler restart.
- Produces per-computer CSV and JSON results plus an action log.
- Supports multiple authorised computers, `-DryRun`, confirmation prompts and clear exit codes.

## Safety

Use only on computers you administer. Remote computers require configured PowerShell remoting and suitable permissions. The framework does not store credentials or automatically discover targets.

## Author

Dewald Pretorius — L2 IT Support Engineer
