class ProjectConfig
{
	[string] $RootPath
	[string] $GitPath
	[string] $GitRepository
	[string] $SourceBranch
	[WorktreeConfig[]] $Worktrees = [WorktreeConfig[]]@()

	static [ProjectConfig] FromJsonFile([string] $jsonPath)
	{
		if(-not (Test-Path $jsonPath))
		{
			return $null
		}
		$converted = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json -NoEnumerate
		if(-not $converted)
		{
			return $null
		}
		$projectConfig = [ProjectConfig]::new()
		$projectConfig.RootPath = $converted.RootPath
		$projectConfig.GitPath = $converted.GitPath
		$projectConfig.GitRepository = $converted.GitRepository
		$projectConfig.SourceBranch = $converted.SourceBranch
		if($converted.Worktrees)
		{
			foreach($worktree in $converted.Worktrees)
			{
				$worktreeConfig = [worktreeConfig]::new()
				$worktreeConfig.Name = $worktree.Name
				$worktreeConfig.InitialCommitish = $worktree.InitialCommitish
				$worktreeConfig.RelativePath = $worktree.RelativePath
				$projectConfig.Worktrees += $worktreeConfig
			}
		}
		return $projectConfig
	}
}
