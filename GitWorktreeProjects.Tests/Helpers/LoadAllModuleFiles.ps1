$modulePath = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', "Modules", "GitWorktreeProjects")).Path

Get-ChildItem (Join-Path $modulePath Types *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $modulePath Config *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $modulePath Tools *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
Get-ChildItem (Join-Path $modulePath ArgumentCompleters *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
