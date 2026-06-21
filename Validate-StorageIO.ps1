#requires -Version 5.1
<# Created by Dewald Pretorius. Read-only storage capacity and disk-status validator. #>
[CmdletBinding()]
param([ValidateRange(1,100)][int]$MinimumFreePercent=15,[string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'Storage_IO_Validation'))
$ErrorActionPreference='Stop';New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null;$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
try{
 $volumes=@(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3'|ForEach-Object{$free=if($_.Size){[math]::Round(($_.FreeSpace/$_.Size)*100,2)}else{0};[pscustomobject]@{Drive=$_.DeviceID;SizeGB=[math]::Round($_.Size/1GB,2);FreeGB=[math]::Round($_.FreeSpace/1GB,2);FreePercent=$free;Pass=($free-ge$MinimumFreePercent)}})
 $physical=@(Get-PhysicalDisk -ErrorAction SilentlyContinue|Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,Size)
 $warnings=@($volumes|Where-Object{-not $_.Pass});$unhealthy=@($physical|Where-Object HealthStatus -ne 'Healthy')
 [ordered]@{Generated=(Get-Date);Threshold=$MinimumFreePercent;Volumes=$volumes;PhysicalDisks=$physical;WarningCount=$warnings.Count;UnhealthyDiskCount=$unhealthy.Count}|ConvertTo-Json -Depth 6|Set-Content -LiteralPath (Join-Path $OutputPath "storage_validation_$stamp.json") -Encoding UTF8
 if($warnings.Count-or$unhealthy.Count){exit 1};exit 0
}catch{Write-Error $_.Exception.Message;exit 5}
