function GetGlobalConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRootPath,

		[Parameter()]
		[String] $DefaultMainBranch,

		[Parameter()]
		[Switch] $SaveChanges
	)

	process
	{
		$globalConfigFileName = "configuration.json"
		$configFilePath = Join-Path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath $globalConfigFileName
		if (Test-Path $configFilePath)
		{
			$config = [GlobalConfig](Get-Content -Path $configFilePath | ConvertFrom-Json)
		}
		else
		{
			Write-Warning "Creating default configuration."
			$config = [GlobalConfig]::new()
		}

		if ($DefaultRootPath)
		{
			if (-not (Test-Path $DefaultRootPath))
			{
				throw "DefaultRootPath '${DefaultRootPath}' must exist!"
			}
			$config.DefaultRootPath = $DefaultRootPath
		}
		if ($DefaultMainBranch)
		{
			$config.DefaultMainBranch = $DefaultMainBranch
		}

		if ($SaveChanges.IsPresent)
		{
			$config | ConvertTo-Json | Out-File -FilePath $configFilePath -Encoding utf8BOM
		}

		$config
	}
}
