$modulePath = Get-Item (Get-Module GitWorktreeProjects | Select-Object -ExpandProperty Path) | Select-Object -ExpandProperty Directory

Get-ChildItem (Join-Path $modulePath Types *.ps1) | ForEach-Object FullName | Resolve-Path | ForEach-Object { . $_ }
