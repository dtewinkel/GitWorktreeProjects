function GetProjects
{
	[OutputType([string[]])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Filter = '*'
	)

	$configPath = GetConfigFilePath -ChildPath *.project
	(Get-ChildItem $configPath -File).BaseName | Where-Object { $PSItem -like $Filter } | Sort-Object
}
