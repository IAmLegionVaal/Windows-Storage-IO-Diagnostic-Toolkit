# Windows Storage IO Diagnostic Toolkit

A read-only PowerShell toolkit for disk, volume, and storage-health reporting.

## Features

- Physical disk and logical volume inventory
- Free-space reporting
- Storage reliability counters where supported
- Recent disk-related event review
- CSV, JSON, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Storage_IO_Diagnostic_Toolkit.ps1
```

## Safety

Read-only reporting only. No storage configuration is changed.
