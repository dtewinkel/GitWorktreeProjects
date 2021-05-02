Describe "WorktreeFilterArgumentCompleter" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/../Helpers/LoadModule.ps1
		. $PSScriptRoot/../Helpers/BackupGitWorktreeConfigPath.ps1
	}

	It "should have the right parameters" {
		$command = Get-Command WorktreeFilterArgumentCompleter
		$command | Should -HaveParameter wordToComplete
		$command | Should -HaveParameter fakeBoundParameters
	}

	It "should expand to nothing when project not found" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "NonExistingProject" } -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project filter not supplied" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{} -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project has no worktrees" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup EmptyProject
		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "MyFirstProject" } -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand to worktrees for all found projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "*" } -wordToComplete "ma"
		$result | Should -HaveCount 3
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main for project AnotherProject"
		$result[1].CompletionText | Should -Be "main"
		$result[1].ListItemText | Should -Be "main"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree main for project MyFirstProject"
		$result[2].CompletionText | Should -Be "master"
		$result[2].ListItemText | Should -Be "master"
		$result[2].ResultType | Should -Be "ParameterValue"
		$result[2].ToolTip | Should -BeLike "Worktree master for project SecondProject"
	}

	It "should expand to the worktrees of the current project" {
		$testConfig = . $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup OneProject
		$ProjectName = "MyFirstProject"

		$rootPath = $testConfig.Projects.${ProjectName}.Project.RootPath
		Mock Get-Location { @{ Path = $rootPath } } -Verifiable

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = '.' } -wordToComplete ""
		Should -InvokeVerifiable
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main for project MyFirstProject"
		$result[1].CompletionText | Should -Be "worktree2"
		$result[1].ListItemText | Should -Be "worktree2"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree worktree2 for project MyFirstProject"
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "MyFirstProject" } -wordToComplete ""
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main for project MyFirstProject"
		$result[1].CompletionText | Should -Be "worktree2"
		$result[1].ListItemText | Should -Be "worktree2"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree worktree2 for project MyFirstProject"
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "MyFirstProject" } -wordToComplete "ma"
		$result | Should -HaveCount 1
		$result[0].CompletionText | Should -Be "main"
		$result[0].ListItemText | Should -Be "main"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree main for project MyFirstProject"
	}

	AfterAll {
		. $PSScriptRoot/../Helpers/RestoreGitWorktreeConfigPath.ps1
		Pop-Location
	}
}
