#requires -Version 5.1
[CmdletBinding()]
param([string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Storage_IO_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$physical=Get-PhysicalDisk -ErrorAction SilentlyContinue|Select-Object FriendlyName,MediaType,BusType,HealthStatus,OperationalStatus,@{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}}
$volumes=Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'|ForEach-Object{[PSCustomObject]@{Drive=$_.DeviceID;VolumeName=$_.VolumeName;FileSystem=$_.FileSystem;SizeGB=[math]::Round($_.Size/1GB,2);FreeGB=[math]::Round($_.FreeSpace/1GB,2);FreePercent=[math]::Round(($_.FreeSpace/$_.Size)*100,2)}}
$physical|Export-Csv (Join-Path $OutputPath "physical_disks_$stamp.csv") -NoTypeInformation -Encoding UTF8
$volumes|Export-Csv (Join-Path $OutputPath "volumes_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Computer=$env:COMPUTERNAME;Generated=Get-Date;PhysicalDisks=$physical;Volumes=$volumes}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "storage_report_$stamp.json") -Encoding UTF8
$html="<h1>Storage IO Diagnostic - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Physical Disks</h2>$($physical|ConvertTo-Html -Fragment)<h2>Volumes</h2>$($volumes|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Storage IO Diagnostic'|Set-Content (Join-Path $OutputPath "storage_report_$stamp.html") -Encoding UTF8
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
