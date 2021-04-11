BeforeAll {
	Push-Location
	. $PSScriptRoot/Helpers/LoadModule.ps1
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
}

Describe "Open-GitWorktree" {

	Context "With <_> configuration" -Foreach 'Custom', 'Default' {

		BeforeAll {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "ThreeProjects"
		}

		It "should fail if the Project does not exist" {
			{
				Open-GitWorktree -Project NonExisting -Worktree None
			} | Should -Throw "Project config File '*Nonexisting.project' for project 'Nonexisting' not found!*"
		}

		It "should fail if the Worktree does not exist" {
			{
				Open-GitWorktree -Project MyFirstProject -Worktree None
			} | Should -Throw "Worktree 'None' for project 'MyFirstProject' not found! Use New-GitWorktree to create it."
		}

		It "should fail if the Worktree path does not exist" {
			$project = $testConfig.Projects.MyFirstProject.Project
			$worktree = $project.Worktrees[1]
			$expectedPath = Join-Path $project.RootPath $worktree.RelativePath

			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedPath } -Verifiable

			{
				Open-GitWorktree -Project MyFirstProject -Worktree worktree2
			} | Should -Throw "Path '$expectedPath' for worktree 'worktree2' in project 'MyFirstProject' not found!"

			Should -InvokeVerifiable
		}

		It "Should change to the right folder for a specific project" {
			$project = $testConfig.Projects.MyFirstProject.Project
			$worktree = $project.Worktrees[0]
			$expectedPath = Join-Path $project.RootPath $worktree.RelativePath
			Mock Set-Location {} -ParameterFilter { $Path -eq $expectedPath } -Verifiable

			Open-GitWorktree -Project MyFirstProject -Worktree main

			Should -InvokeVerifiable
		}

		It "Should change to the right folder for the current project" {
			$project = $testConfig.Projects.SecondProject.Project
			$worktree = $project.Worktrees[0]
			$expectedPath = Join-Path $project.RootPath $worktree.RelativePath

			Mock Get-Location { @{ Path = $project.RootPath } } -Verifiable
			Mock Set-Location {} -ParameterFilter { $Path -eq $expectedPath } -Verifiable

			Open-GitWorktree -Project . -Worktree main

			Should -InvokeVerifiable
		}

		It "Should fail if outside a project for the current project" {

			Mock Get-Location { @{ Path = "dummy" } } -Verifiable
			Mock Set-Location {}

			{
				Open-GitWorktree -Project . -Worktree any
			} | Should -Throw "Could not determine the Project in the current directory."

			Should -InvokeVerifiable
			Should -Not -Invoke Set-Location
		}
	}

	Context "With <_> configuration" -Foreach 'Custom', 'Default' {

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
