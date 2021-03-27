function GetProjects
{
	[OutputType([string[]])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Filter = '*'
	)

	$path = GetConfigFilePath -ChildPath *.project
	(Get-ChildItem $path -File).BaseName | Where-Object { $PSItem -like $Filter }
}
