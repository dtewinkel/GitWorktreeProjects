function GetGlobalConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param()

	$config = GetConfigFile -FileName "configuration.json"

	if ($config)
	{
		[GlobalConfig]::FromFile($config)
	}
	if (-not $config)
	{
		Write-Warning "Global configuration file 'configuration.json' not found! Using default configuration."
		[GlobalConfig]::new()
	}
}
