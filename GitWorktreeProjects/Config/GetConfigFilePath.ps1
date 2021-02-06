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
			$configFilePath = Join-Path -Path ${HOME} -ChildPath .gitworktree
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
