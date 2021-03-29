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
		$null = New-Item -ItemType Directory -Path $configPath
	}
	$configFile = GetConfigFilePath -ChildPath "configuration.json"

	$GlobalConfig.ToFile() | ConvertTo-Json -Depth 5 | Out-File -FilePath $configFile -Encoding utf8BOM
}
