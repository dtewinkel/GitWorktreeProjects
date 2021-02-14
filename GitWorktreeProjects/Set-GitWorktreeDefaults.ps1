function Set-GitWorktreeDefaults
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRoot,

		[Parameter()]
		[String] $DefaultBranch
	)

	process
	{
		$globalConfig = GetGlobalConfig

		if ($DefaultRoot)
		{
				if (-not (Test-Path -Path $DefaultRoot))
				{
						throw "DefaultRooth '${DefaultRoot}' must exist!"
				}
				$globalConfig.DefaultRootPath = $DefaultRoot
		}
		if ($DefaultBranch)
		{
				$globalConfig.DefaultSourceBranch = $DefaultBranch
		}

		SetGlobalConfig -GlobalConfig $globalConfig

		$globalConfig
	}
}
