[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "Get-GitWorktreeProject" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktreeProject

		$command | Should -HaveParameter WorktreeFilter
		. $PSScriptRoot/Helpers/HasArgumentCompleter.ps1 -CommandName Get-GitWorktreeProject -ParameterName WorktreeFilter | Should -BeTrue

		$command | Should -HaveParameter ProjectFilter
		. $PSScriptRoot/Helpers/HasArgumentCompleter.ps1 -CommandName Get-GitWorktreeProject -ParameterName ProjectFilter | Should -BeTrue
	}

	It "should get project information for a specific project" {
		$ProjectName = "SecondProject"
		$ExpectedProject = @{}

		Mock GetProjects { @( $ProjectName ) } -ParameterFilter { $Filter -eq $ProjectName } -Verifiable -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject } -ParameterFilter { $Project -eq $ProjectName -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects

		$result = Get-GitWorktreeProject -ProjectFilter $ProjectName

		Should -InvokeVerifiable
		$result | Should -Be $ExpectedProject
	}

	It "Should return information about all projects if called without parameters" {

		$Project1Name = "FirstProject"
		$Project2Name = "SecondProject"
		$ExpectedProject1 = @{}
		$ExpectedProject2 = @{}

		Mock GetProjects { @( $Project1Name, $Project2Name ) } -ParameterFilter { $Filter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject1 } -ParameterFilter { $Project -eq $Project1Name -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject2 } -ParameterFilter { $Project -eq $Project2Name -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects

		$result = Get-GitWorktreeProject

		Should -InvokeVerifiable
		$result | Should -Be @( $ExpectedProject1, $ExpectedProject2 )
	}

	It "Should return information about the current project" {

		$ExpectedProject = @{}

		Mock GetProjects {  } -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject } -ParameterFilter { $Project -eq '.' -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects

		$result = Get-GitWorktreeProject -ProjectFilter .

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjects -ModuleName GitWorktreeProjects
		$result | Should -Be $ExpectedProject
	}
}
