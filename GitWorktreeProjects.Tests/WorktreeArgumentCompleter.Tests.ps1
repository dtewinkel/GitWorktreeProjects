Describe "WorktreeArgumentCompleter" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/Helpers/LoadModule.ps1
		. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
	}

	It "should have the right parameters" {
		$command = Get-Command WorktreeArgumentCompleter
		$command | Should -HaveParameter wordToComplete
		$command | Should -HaveParameter fakeBoundParameters
	}

	It "should expand to nothing when project not found" {
		. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
		$result = WorktreeArgumentCompleter -fakeBoundParameters @{ Project = "NonExistingProject" } -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project has no worktrees" {
		. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup EmptyProject
		$result = WorktreeArgumentCompleter -fakeBoundParameters @{ Project = "MyFirstProject" } -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand to the worktrees of the current project" {
		$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup OneProject
		$ProjectName = "MyFirstProject"

		$rootPath = $testConfig.Projects.${ProjectName}.Project.RootPath
		Mock Get-Location { @{ Path = $rootPath } } -Verifiable

		$result = WorktreeArgumentCompleter -fakeBoundParameters @{ Project = '.' } -wordToComplete ""
		Should -InvokeVerifiable
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main in main"
		$result[1].CompletionText | Should -Be "worktree2"
		$result[1].ListItemText | Should -Be "worktree2"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree worktree2 in worktree2"
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects

		$result = WorktreeArgumentCompleter -fakeBoundParameters @{ Project = "MyFirstProject" } -wordToComplete ""
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main in main"
		$result[1].CompletionText | Should -Be "worktree2"
		$result[1].ListItemText | Should -Be "worktree2"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree worktree2 in anotherTree"
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
		$result = WorktreeArgumentCompleter -fakeBoundParameters @{ Project = "MyFirstProject" } -wordToComplete "ma"
		$result | Should -HaveCount 1
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main in main"
	}

	AfterAll {
		. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
		Pop-Location
	}
}
