function GetProjects
{
	[OutputType([ProjectConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Filter = ''
	)

	process
	{
		$path = GetConfigFilePath -ChildPath *.project
		(Get-ChildItem $path -File).BaseName | Where-Object { $PSItem -like $Filter }
	}
}
