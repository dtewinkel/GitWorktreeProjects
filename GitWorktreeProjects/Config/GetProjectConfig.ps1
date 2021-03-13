function GetProjectConfig
{
	[OutputType([Project])]
	[OutputType([Void])]
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*',

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
	$projectConfig = [Project]::FromProjectFile($projectFromFile)
	$projectConfig.Worktrees = $projectConfig.Worktrees | Where-Object Name -Like $WorktreeFilter
	if ($WorktreeFilter -eq '*' -or $projectConfig.Worktrees.Length -ne 0)
	{
		$projectConfig
	}
}
