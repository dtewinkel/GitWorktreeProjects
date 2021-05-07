class Tool
{
	[string] $Name
	[string[]] $Parameters = [string[]]@()
}

class Worktree
{
	[string] $Name
	[string] $InitialCommitish
	[string] $RelativePath
	[string] $NewBranch
	[Tool[]] $Tools = [Tool[]]@()
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
	[Tool[]] $Tools = [Tool[]]@()
}

class Project
{
	[string] $Name
	[string] $RootPath
	[string] $GitPath
	[string] $GitRepository
	[string] $SourceBranch
	[Worktree[]] $Worktrees = [Worktree[]]@()
	[Tool[]] $Tools = [Tool[]]@()

	static [Project] FromFile([ProjectFile] $projectConfig)
	{
		$project = [Project]::new()
		$project.Name = $projectConfig.Name
		$project.RootPath = $projectConfig.RootPath
		$project.GitPath = $projectConfig.GitPath
		$project.GitRepository = $projectConfig.GitRepository
		$project.SourceBranch = $projectConfig.SourceBranch
		$project.Worktrees = $projectConfig.Worktrees
		$project.Tools = $projectConfig.Tools

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
		$projectFile.Tools = $this.Tools

		return $projectFile
	}
}
