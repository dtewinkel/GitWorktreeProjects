function GetProjectConfig
{
	[OutputType([ProjectConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project
	)

	process
	{
		$projectConfigFileName = "${Project}.project"
		$configFilePath = $env:GitWorktreeConfigPath
		if(-not $configFilePath)
		{
			$configFilePath = Join-Path -Path ${HOME} -ChildPath .gitworktree
		}
		$configFile = Join-Path -Path $configFilePath -ChildPath $projectConfigFileName
		if (-not (Test-Path $configFile))
		{
			throw "Project Config File '${configFile}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		[ProjectConfig](Get-Content -Path $configFile | ConvertFrom-Json)
	}
}
