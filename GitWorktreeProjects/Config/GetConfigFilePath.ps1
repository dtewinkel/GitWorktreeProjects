function GetConfigFilePath
{
	[OutputType([string])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $ChildPath
	)

	process
	{
		$configFilePath = $env:GitWorktreeConfigPath
		if(-not $configFilePath)
		{
			$configPath = $env:UserProfile
			if(-not $configPath)
			{
				$configPath = "${env:HOMEDRIVE}${env:HOMEPATH}"
			}
			if(-not $configPath)
			{
				$configPath = $env:HOME
			}
			if(-not $configPath)
			{
				throw "Cannot determine location of GitWorktreeProject configuration files."
			}
			$configFilePath = Join-Path $configPath .gitworktree
		}
		if($ChildPath)
		{
			Join-Path -Path $configFilePath -ChildPath $ChildPath
		}
		else
		{
			$configFilePath
		}
	}
}
