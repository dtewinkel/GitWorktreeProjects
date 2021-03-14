class Worktree
{
	[string] $Name
	[string] $InitialCommitish
	[string] $RelativePath
	[string] $NewBranch
}

class ProjectFile
{
	[int] $SchemaVersion
	[string] $Name
	[string] $RootPath
	[string] $GitPath
	[string] $GitRepository
	[string] $SourceBranch
	[Worktree[]] $Worktrees = [Worktree[]]@()
}

class Project
{
	[string] $Name
	[string] $RootPath
	[string] $GitPath
	[string] $GitRepository
	[string] $SourceBranch
	[Worktree[]] $Worktrees = [Worktree[]]@()

	static [Project] FromProjectFile([ProjectFile] $projectConfig)
	{
		$project = [Project]::new()
		$project.Name = $projectConfig.Name
		$project.RootPath = $projectConfig.RootPath
		$project.GitPath = $projectConfig.GitPath
		$project.GitRepository = $projectConfig.GitRepository
		$project.SourceBranch = $projectConfig.SourceBranch
		$project.Worktrees = $projectConfig.Worktrees

		return $project
	}

	[ProjectFile] ToFile()
	{
		$projectFile = [ProjectFile]::new()
		$projectFile.SchemaVersion = 1
		$projectFile.Name = $this.Name
		$projectFile.RootPath = $this.RootPath
		$projectFile.GitPath = $this.GitPath
		$projectFile.GitRepository = $this.GitRepository
		$projectFile.SourceBranch = $this.SourceBranch
		$projectFile.Worktrees = $this.Worktrees
		return $projectFile
	}
}
