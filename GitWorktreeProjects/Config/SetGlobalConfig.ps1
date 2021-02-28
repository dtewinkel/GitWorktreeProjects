function SetGlobalConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[GlobalConfig] $GlobalConfig
	)

	$configPath = GetConfigFilePath
	if(-not (Test-Path $configPath))
	{
		New-Item -ItemType Directory -Path $configPath
	}
	$configFile = GetConfigFilePath -ChildPath "configuration.json"

	$GlobalConfig.ToFile() | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8BOM
}
