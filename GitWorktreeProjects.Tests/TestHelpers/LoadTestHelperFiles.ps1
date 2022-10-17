[CmdletBinding()]
param (
)

Get-ChildItem (Join-Path $PSScriptRoot Functions *.ps1) | ForEach-Object FullName | ForEach-Object { . $_ }
