function GetConfigFilePath
{
	[OutputType([string])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $ChildPath
	)

	function GetFromEnv($VarName)
	{
		(Get-Item "Env:${VarName}" -ErrorAction SilentlyContinue).Value
	}

	$configFilePath = GetFromEnv GitWorktreeConfigPath
	if (-not $configFilePath)
	{
		$configPath = GetFromEnv USERPROFILE
		if (-not $configPath)
		{
			$configPath = "$(GetFromEnv HOMEDRIVE)$(GetFromEnv HOMEPATH)"
		}
		if (-not $configPath)
		{
			$configPath = GetFromEnv HOME
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
