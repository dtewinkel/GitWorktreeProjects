[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "GetProjects" {

	BeforeAll {

		$projectItems = @(
			@{
				BaseName = "Project1"
			}
			@{
				BaseName = "Demo2"
			}
			@{
				BaseName = "Project2"
			}
			@{
				BaseName = "Demo1"
			}
		)

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command GetProjects
		$command | Should -HaveParameter Filter
	}

	It "should throw if GetConfigFilePath throws" {

		Mock GetConfigFilePath { throw "Oops!" }

		{ GetProjects } | Should -Throw "Oops!"
	}

	It "returns nothing if no project exists" {

		Mock GetConfigFilePath { '/config/*.project' } -ParameterFilter { $ChildPath -eq '*.project' } -Verifiable
		Mock Get-ChildItem { @() } -ParameterFilter { $Path -eq '/config/*.project' } -Verifiable

		$projects = GetProjects

		Should -InvokeVerifiable
		$projects | Should -BeNullOrEmpty
	}

	It "returns all projects if filter is not specified" {

		Mock GetConfigFilePath { '/config/*.project' } -ParameterFilter { $ChildPath -eq '*.project' } -Verifiable
		Mock Get-ChildItem { $projectItems } -ParameterFilter { $Path -eq '/config/*.project' } -Verifiable

		$projects = GetProjects

		Should -InvokeVerifiable
		$projects | Should -HaveCount 4
		$projects[0] | Should -Be "Demo1"
		$projects[1] | Should -Be "Demo2"
		$projects[2] | Should -Be "Project1"
		$projects[3] | Should -Be "Project2"
	}

	It "returns matching projects" {

		Mock GetConfigFilePath { '/config/*.project' } -ParameterFilter { $ChildPath -eq '*.project' } -Verifiable
		Mock Get-ChildItem { $projectItems } -ParameterFilter { $Path -eq '/config/*.project' } -Verifiable

		$projects = GetProjects -Filter 'De*'

		Should -InvokeVerifiable
		$projects | Should -HaveCount 2
		$projects[0] | Should -Be "Demo1"
		$projects[1] | Should -Be "Demo2"
	}
}
