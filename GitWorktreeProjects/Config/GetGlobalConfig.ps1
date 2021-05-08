function GetGlobalConfig
{
	[cmdletbinding()]
	param()

	$config = GetConfigFile -FileName "configuration.json"

	if ($config)
	{
		return [GlobalConfig]::FromFile($config)
	}

	Write-Warning "Global configuration file 'configuration.json' not found! Using default configuration."
	return [GlobalConfig]::new()
}
