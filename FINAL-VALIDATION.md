# Storage validation

Run:

```powershell
.\Validate-StorageIO.ps1 -MinimumFreePercent 20
```

Created by **Dewald Pretorius**. The script reports free-space thresholds and disk health without changing storage configuration. Exit codes are `0` pass, `1` review, and `5` error.
