function GetGlobalConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param()

	process
	{
		$configFile = GetConfigFilePath -ChildPath "configuration.json"

		if (Test-Path -Path $configFile)
		{
			$config = [GlobalConfig]::FromJsonFile($configFile)
		}
		else
		{
			Write-Warning "Creating default configuration."
			$config = [GlobalConfig]::new()
		}
		$config
	}
}
