[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "Get-GitWorktree" {

	BeforeEach {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder

		$projectName = "Testing123"
		$worktrees = @(
			@{
				Name = "Test123"
			}
			@{
				Name = "Demo123"
			}
		)

		$projectConfig = @{
			SchemaVersion = 1
			Name          = $projectName
			Worktrees     = $worktrees
		}
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktree

		$command | Should -HaveParameter WorktreeFilter -HasArgumentCompleter
		$command | Should -HaveParameter Project -HasArgumentCompleter
	}

	It "should return all worktrees for the currenct project if no parameters are given" {

		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq '*' } -Verifiable

		$worktrees = Get-GitWorktree

		Should -InvokeVerifiable
		$worktrees | Should -HaveCount 2
		$worktrees[0].Name | Should -Be "Test123"
		$worktrees[1].Name | Should -Be "Demo123"
	}

	It "should return all worktrees for the project and worktrees for which the parameters are given" {

		$projectFilter = 'Testing123'
		$worktreeFilter = '*123'
		Mock GetProjects { @( $projectFilter ) } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectFilter } -Verifiable
		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq $projectFilter -and $WorktreeFilter -eq $WorktreeFilter } -Verifiable

		$worktrees = Get-GitWorktree -Project $projectFilter -WorktreeFilter $worktreeFilter

		Should -InvokeVerifiable
		$worktrees | Should -HaveCount 2
		$worktrees[0].Name | Should -Be "Test123"
		$worktrees[1].Name | Should -Be "Demo123"
	}

	It "should return an empty array if no match for the project and worktrees for which the parameters are given" {

		$projectFilter = 'Testing123'
		$worktreeFilter = 'None'
		$projectConfig.Worktrees = @()
		Mock GetProjects { @( $projectFilter ) } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectFilter } -Verifiable
		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq $projectFilter -and $WorktreeFilter -eq $WorktreeFilter } -Verifiable

		$worktrees = Get-GitWorktree -Project $projectFilter -WorktreeFilter $worktreeFilter

		Should -InvokeVerifiable
		$worktrees.GetType() | Should -Be 'Worktree[]'
		$worktrees | Should -BeNullOrEmpty
	}

	It "should fail if -Project is not '.' and no project can be found" {

		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects
		Mock GetProjects { } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectName } -Verifiable
		$projectName = 'Test*'

		{ Get-GitWorktree -Project $projectName } | Should -Throw "No project found with name ${projectName}. Make sure the name is correct and that no wildcards are used that match more than one project."

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjectConfig -ModuleName GitWorktreeProjects
	}

	It "should fail if -Project is not '.' and more than one project is found" {

		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects
		Mock GetProjects { @(1, 2) } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectName } -Verifiable
		$projectName = 'Test*'

		{ Get-GitWorktree -Project $projectName } | Should -Throw "No project found with name ${projectName}. Make sure the name is correct and that no wildcards are used that match more than one project."

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjectConfig -ModuleName GitWorktreeProjects
	}
}
