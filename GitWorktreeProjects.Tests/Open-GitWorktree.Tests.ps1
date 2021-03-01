BeforeAll {
	Push-Location
	. $PSScriptRoot/Helpers/LoadModule.ps1
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
}

Describe "Open-GitWorktree" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeAll {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "OneProject"
		}

		It "should fail if the Project does not exist" {
			{
				Open-GitWorktree -Project NonExisting -Worktree None
			} | Should -Throw "Project config File '*Nonexisting.project' for project 'Nonexisting' not found!*"
		}

		It "should fail if the Worktree does not exist" {
			{
				Open-GitWorktree -Project MyFirstProject -Worktree None
			} | Should -Throw "Worktree 'None' for project 'MyFirstProject' not found!"
		}

		It "should fail if the Worktree path does not exist" {
			$project = $testConfig.Projects.MyFirstProject.Project
			$worktree = $project.Worktrees[1]
			$expectedPath = Join-Path $project.RootPath $worktree.RelativePath

			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedPath }
			{
				Open-GitWorktree -Project MyFirstProject -Worktree worktree2
			} | Should -Throw "Path '$expectedPath' for worktree 'worktree2' in project 'MyFirstProject' not found!"
		}

		It "Should change to the right folder" {
			$project = $testConfig.Projects.MyFirstProject.Project
			$worktree = $project.Worktrees[0]
			$expectedPath = Join-Path $project.RootPath $worktree.RelativePath
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedPath }
			Mock Set-Location {}
			Open-GitWorktree -Project MyFirstProject -Worktree main
			Should -Invoke Set-Location -Times 1 -ParameterFilter { $Path -eq $expectedPath }
		}
	}

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeAll {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "ErrorProjects"
		}

		It "should fail if Project file has wrong version" {
			{
				Open-GitWorktree -Project WrongVersion -Worktree Test
			} | Should -Throw "Schema version '0' is not supported for file 'WrongVersion.project' (*WrongVersion.project)."
		}
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
	Pop-Location
}
