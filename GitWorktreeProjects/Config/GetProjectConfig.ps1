function GetProjectConfig
{
	[OutputType([ProjectConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	process
	{
		$configFile = GetConfigFilePath -ChildPath "${Project}.project"
		if (-not (Test-Path $configFile))
		{
			throw "Project Config File '${configFile}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		$projectConfig = [ProjectConfig]::FromJsonFile($configFile)
		$projectConfig.Worktrees = $projectConfig.Worktrees | Where-Object Name -like $WorktreeFilter
		if($WorktreeFilter -eq '*' -or $projectConfig.Worktrees.Length -ne 0)
		{
			$projectConfig
		}
	}
}
