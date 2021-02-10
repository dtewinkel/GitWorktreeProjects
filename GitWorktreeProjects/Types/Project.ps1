class Project
{
	[string] $Name
	[string] $RootPath
	[string] $GitPath
	[string] $GitRepository
	[string] $SourceBranch
	[Worktree[]] $Worktrees = [Worktree[]]@()

	static [Project] FromProjectConfig([string] $name, [ProjectConfig] $projectConfig)
	{
		if ($null -eq $projectConfig)
		{
			return $null
		}
		$project = [Project]::new()
		$project.Name = $name
		$project.RootPath = $projectConfig.RootPath
		$project.GitPath = $projectConfig.GitPath
		$project.GitRepository = $projectConfig.GitRepository
		$project.SourceBranch = $projectConfig.SourceBranch
		if ($projectConfig.Worktrees -and $projectConfig.Worktrees.Count -gt 0)
		{
			foreach ($worktreeInfo in $projectConfig.Worktrees)
			{
				$worktree = [Worktree]::new()
				$worktree.Name = $worktreeInfo.Name
				$worktree.InitialCommitish = $worktreeInfo.InitialCommitish
				$worktree.RelativePath = $worktreeInfo.RelativePath
				$project.Worktrees += $worktree
			}
		}
		return $project
	}
}
