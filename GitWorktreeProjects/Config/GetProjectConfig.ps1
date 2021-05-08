function GetProjectConfig
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*',

		[Parameter()]
		[Switch] $WorktreeExactMatch,

		[Parameter()]
		[Switch] $FailOnMissing
	)

	if ($Project -eq '.')
	{
		$Project = GetCurrentProject
		if (-not $Project)
		{
			if ($FailOnMissing.IsPresent)
			{
				throw "Could not determine the Project in the current directory."
			}
			return $null
		}
	}

	$fileName = "${Project}.project"
	$projectFromFile = GetConfigFile -FileName $fileName
	if (-not $projectFromFile)
	{
		if ($FailOnMissing.IsPresent)
		{
			throw "Project Config File '${fileName}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		return $null
	}
	$projectConfig = [Project]::FromFile($projectFromFile)
	if ($WorktreeExactMatch.IsPresent)
	{
		$projectConfig.Worktrees = $projectConfig.Worktrees | Where-Object Name -ceq $WorktreeFilter
		if ((-not $projectConfig.Worktrees -or $projectConfig.Worktrees.Length -ne 1) -and $FailOnMissing.IsPresent)
		{
			throw "Worktree '$WorktreeFilter' for project '${Project}' not found! Use New-GitWorktree to create it."
		}
	}
	else
	{
		$projectConfig.Worktrees = $projectConfig.Worktrees | Where-Object Name -like $WorktreeFilter
	}
	if ($WorktreeFilter -eq '*' -or $projectConfig.Worktrees.Length -ne 0)
	{
		$projectConfig
	}
}
