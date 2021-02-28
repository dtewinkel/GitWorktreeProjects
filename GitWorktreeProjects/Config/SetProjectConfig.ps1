function SetProjectConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project,

		[Parameter()]
		[ProjectConfig] $ProjectConfig
	)

	process
	{
		$configFilePath = GetConfigFilePath -ChildPath "${Project}.project"
		$ProjectConfig.ToFile() | ConvertTo-Json | Out-File $configFilePath -Encoding utf8BOM
	}
}
