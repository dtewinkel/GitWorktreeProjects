function GetGlobalConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRootPath,

		[Parameter()]
		[String] $DefaultSourceBranch,

		[Parameter()]
		[Switch] $SaveChanges
	)

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

		if ($DefaultRootPath)
		{
			if (-not (Test-Path -Path $DefaultRootPath))
			{
				throw "DefaultRootPath '${DefaultRootPath}' must exist!"
			}
			$config.DefaultRootPath = $DefaultRootPath
		}
		if ($DefaultSourceBranch)
		{
			$config.DefaultSourceBranch = $DefaultSourceBranch
		}

		if ($SaveChanges.IsPresent)
		{
			$config | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8BOM
		}

		$config
	}
}
