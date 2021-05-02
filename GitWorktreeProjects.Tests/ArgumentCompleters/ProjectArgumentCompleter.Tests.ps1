Describe "ProjectArgumentCompleter" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/../Helpers/LoadModule.ps1
		. $PSScriptRoot/../Helpers/BackupGitWorktreeConfigPath.ps1
	}

	It "should have the right parameters" {
		$command = Get-Command ProjectArgumentCompleter
		$command | Should -HaveParameter wordToComplete
	}

	It "should expand to nothing when no projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
		$result = ProjectArgumentCompleter -wordToComplete ""
		$result | Should -BeNullOrEmpty
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects

		$result = ProjectArgumentCompleter -wordToComplete ""
		$result | Should -HaveCount 3
		$result[0].CompletionText | Should -Be "AnotherProject"
		$result[0].ListItemText | Should -Be "AnotherProject"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Project AnotherProject in*"
		$result[1].CompletionText | Should -Be "MyFirstProject"
		$result[1].ListItemText | Should -Be "MyFirstProject"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Project MyFirstProject in*"
		$result[2].CompletionText | Should -Be "SecondProject"
		$result[2].ListItemText | Should -Be "SecondProject"
		$result[2].ResultType | Should -Be "ParameterValue"
		$result[2].ToolTip | Should -BeLike "Project SecondProject in*"
	}

	It "should expand ProjectFilter to nothing with 3 projects" {
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
		$result = ProjectArgumentCompleter -wordToComplete "Se"
		$result | Should -HaveCount 1
		$result[0].CompletionText | Should -Be "SecondProject"
		$result[0].ListItemText | Should -Be "SecondProject"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Project SecondProject in*"
	}

	AfterAll {
		. $PSScriptRoot/../Helpers/RestoreGitWorktreeConfigPath.ps1
		Pop-Location
	}
}
