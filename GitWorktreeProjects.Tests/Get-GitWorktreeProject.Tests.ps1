[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "Get-GitWorktreeProject" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktreeProject

		$command | Should -HaveParameter WorktreeFilter -HasArgumentCompleter
		$command | Should -HaveParameter ProjectFilter -HasArgumentCompleter
	}

	It "should get project information for a specific project" {
		$ProjectName = "SecondProject"
		$ExpectedProject = @{ Name = $ProjectName }

		Mock GetProjects { @( $ProjectName ) } -ParameterFilter { $Filter -eq $ProjectName } -Verifiable -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject } -ParameterFilter { $Project -eq $ProjectName -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects

		$result = Get-GitWorktreeProject -ProjectFilter $ProjectName

		Should -InvokeVerifiable
		Test-Equality $result, $ExpectedProject | Should -Be $true -Because "boo"
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
		Test-Equality $result, @( $ExpectedProject1, $ExpectedProject2 ) | Should -Be $true -Because "boo"
	}

	It "Should return information about the current project" {

		$ExpectedProject = @{}

		Mock GetProjects {  } -ModuleName GitWorktreeProjects
		Mock GetProjectConfig { $ExpectedProject } -ParameterFilter { $Project -eq '.' -and $WorkTreeFilter -eq '*' } -Verifiable -ModuleName GitWorktreeProjects

		$result = Get-GitWorktreeProject -ProjectFilter .

		Should -InvokeVerifiable
		Should -Not -Invoke GetProjects -ModuleName GitWorktreeProjects
		Test-Equality $result, $ExpectedProject | Should -Be $true -Because "boo"
	}
}
