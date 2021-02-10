function GetProjectConfig
{
	[OutputType([ProjectConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project
	)

	process
	{
		$configFile = GetConfigFilePath -ChildPath "${Project}.project"
		if (-not (Test-Path $configFile))
		{
			throw "Project Config File '${configFile}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		[ProjectConfig]::FromJsonFile($configFile)
	}
}
