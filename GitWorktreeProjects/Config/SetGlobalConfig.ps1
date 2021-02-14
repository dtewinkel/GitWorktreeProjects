function SetGlobalConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[GlobalConfig] $GlobalConfig
	)

	process
	{
		$configFile = GetConfigFilePath -ChildPath "configuration.json"

		$GlobalConfig | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8BOM
	}
}
