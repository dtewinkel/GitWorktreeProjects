function get-GetProjectConfig
{
	[OutputType([Project])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	process
	{
		$fileName = "${Project}.project"
		$projectFromFile = GetConfigFile -FileName $fileName
		if (-not $projectFromFile)
		{
			throw "Project Config File '${fileName}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		$projectConfig = [Project]::FromProjectFile($projectFromFile)
		$projectConfig.Worktrees = $projectConfig.Worktrees | Where-Object Name -like $WorktreeFilter
		if($WorktreeFilter -eq '*' -or $projectConfig.Worktrees.Length -ne 0)
		{
			$projectConfig
		}
	}
}
