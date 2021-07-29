function GetConfigFilePath
{
	[OutputType([string])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $ChildPath
	)

	$configFilePath = __GitWorktree_GetFromEnv GitWorktreeConfigPath
	if (-not $configFilePath)
	{
		$configPath = __GitWorktree_GetFromEnv USERPROFILE
		if (-not $configPath)
		{
			$configPath = "$(__GitWorktree_GetFromEnv HOMEDRIVE)$(__GitWorktree_GetFromEnv HOMEPATH)"
		}
		if (-not $configPath)
		{
			$configPath = __GitWorktree_GetFromEnv HOME
		}
		if (-not $configPath)
		{
			throw "Cannot determine location of GitWorktreeProject configuration files."
		}
		$configFilePath = Join-Path $configPath .gitworktree
	}
	if ($ChildPath)
	{
		return Join-Path -Path $configFilePath -ChildPath $ChildPath
	}
	return $configFilePath
}
