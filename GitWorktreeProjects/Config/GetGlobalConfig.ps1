function GetGlobalConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRootPath,

		[Parameter()]
		[String] $DefaultBranch,

		[Parameter()]
		[Switch] $SaveChanges
	)

	process
	{
		$configFile = GetConfigFilePath -ChildPath "configuration.json"

		if (Test-Path -Path $configFile)
		{
			$config = [GlobalConfig](Get-Content -Path $configFile | ConvertFrom-Json)
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
		if ($DefaultBranch)
		{
			$config.DefaultMainBranch = $DefaultBranch
		}

		if ($SaveChanges.IsPresent)
		{
			$config | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8BOM
		}

		$config
	}
}
