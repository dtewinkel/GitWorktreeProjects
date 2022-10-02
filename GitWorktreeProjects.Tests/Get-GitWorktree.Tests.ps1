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

		$projectConfigs = & $PSScriptRoot/Helpers/GetTestProjectConfig.ps1
		$projectConfig = $projectConfigs[0]
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktree

		$command | Should -HaveParameter Project -HasArgumentCompleter -DefaultValue '.' -Type [string]
		$command | Should -HaveParameter WorktreeFilter -HasArgumentCompleter -DefaultValue '*' -Alias 'Filter' -Type [string]
	}

	It "should return all working trees for the project if a project is specified" {

		$projectFilter = 'Testing123'
		Mock GetProjects { @( $projectFilter ) } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectFilter } -Verifiable
		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq $projectFilter -and $WorktreeFilter -eq '*' } -Verifiable

		$worktrees = Get-GitWorktree -Project $projectFilter

		Should -InvokeVerifiable
		$worktrees | Should -HaveCount 3
		$worktrees[0].Name | Should -Be "main"
		$worktrees[1].Name | Should -Be "Test123"
		$worktrees[2].Name | Should -Be "Demo123"
	}

	It "should return all working trees for the currenct project if -Project is '.'" {

		Mock GetProjects { } -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq '*' } -Verifiable

		$worktrees = Get-GitWorktree -Project '.'

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjects -ModuleName GitWorktreeProjects
		$worktrees | Should -HaveCount 3
		$worktrees[0].Name | Should -Be "main"
		$worktrees[1].Name | Should -Be "Test123"
		$worktrees[2].Name | Should -Be "Demo123"
	}

	It "should fail if -Project is not '.' and no project can be found" {

		$projectName = 'Test*'
		Mock GetProjects { } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectName } -Verifiable
		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects

		{ Get-GitWorktree -Project $projectName } | Should -Throw "No project found with name ${projectName}. Make sure the name is correct."

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjectConfig -ModuleName GitWorktreeProjects
	}

	It "should fail if -Project is not '.' and more than one project is found" {

		$projectName = 'Test*'
		Mock GetProjects { $projectConfigs } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Filter -eq $projectName } -Verifiable
		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects

		{ Get-GitWorktree -Project $projectName } | Should -Throw "Multiple projects found that match name ${projectName}. Make sure the name is correct and that no wildcards are used that match more than one project."

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjectConfig -ModuleName GitWorktreeProjects
	}

	It "should return all working trees for the currenct project if no parameters are given" {

		Mock GetProjects { } -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $projectConfig } -ModuleName GitWorktreeProjects `
			-ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq '*' } -Verifiable

		$worktrees = Get-GitWorktree

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjects -ModuleName GitWorktreeProjects
		$worktrees | Should -HaveCount 3
		$worktrees[0].Name | Should -Be "main"
		$worktrees[1].Name | Should -Be "Test123"
		$worktrees[2].Name | Should -Be "Demo123"
	}

	It "should return all working trees for the project and working trees for which the parameters are given" {

		$projectFilter = 'Testing123'
		$worktreeFilter = '*123'
		$projectConfig.Worktrees = $projectConfig.Worktrees[1..2]

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

	It "should return an empty array if no match for the project and working trees combination for which the parameters are given" {

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
}
