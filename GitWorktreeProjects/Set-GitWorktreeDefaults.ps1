function Set-GitWorktreeDefaults
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRoot,

		[Parameter()]
		[String] $DefaultBranch,

		[Parameter()]
		[String[]] $DefaultTools
	)

	if (-not $DefaultRoot -and -not $DefaultBranch -and -not $DefaultTools)
	{
		throw "At least either -DefaultRoot, -DefaultBranch, or -DefaultTools must be specified!"
	}

	$globalConfig = GetGlobalConfig

	if ($DefaultRoot)
	{
		if (-not (Test-Path -Path $DefaultRoot))
		{
			throw "DefaultRoot '${DefaultRoot}' must exist!"
		}
		$globalConfig.DefaultRootPath = $DefaultRoot
	}
	if ($DefaultBranch)
	{
		$globalConfig.DefaultSourceBranch = $DefaultBranch
	}

	if ($DefaultTools)
	{
		$globalConfig.DefaultTools = $DefaultTools
	}

	SetGlobalConfig -GlobalConfig $globalConfig
}
