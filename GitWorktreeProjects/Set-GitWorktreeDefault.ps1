function Set-GitWorktreeDefault
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRoot,

		[Parameter()]
		[ArgumentCompletion('main', 'develop', 'trunk', 'root', 'dev', 'primary', 'master')]
		[String] $DefaultBranch
	)

	if (-not $DefaultRoot -and -not $DefaultBranch)
	{
		throw "At least either -DefaultRoot or -DefaultBranch must be specified!"
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

	SetGlobalConfig -GlobalConfig $globalConfig
}
