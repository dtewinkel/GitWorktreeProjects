[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "ProjectArgumentCompleter" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command ProjectArgumentCompleter
		$command | Should -HaveParameter wordToComplete
	}

	It "should expand to nothing when no projects" {

		Mock GetProjects { @() } -ParameterFilter { $Filter -eq '*' } -Verifiable

		$result = ProjectArgumentCompleter -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand the projects based on the filter" {

		Mock GetProjects { @("P1", "P2", "3") } -ParameterFilter { $Filter -eq '*' } -Verifiable
		Mock GetProjectConfig { @{ Name = 'P1'; RootPath = '/pr/p1' } } -ParameterFilter { $Project -eq 'P1' } -Verifiable
		Mock GetProjectConfig { @{ Name = 'P2'; RootPath = '/p2' } } -ParameterFilter { $Project -eq 'P2' } -Verifiable
		Mock GetProjectConfig { @{ Name = '3'; RootPath = '/p3' } } -ParameterFilter { $Project -eq '3' } -Verifiable

		$result = ProjectArgumentCompleter -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -HaveCount 3
		$result[0].CompletionText | Should -Be "P1"
		$result[0].ListItemText | Should -Be "P1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -Be "Project P1 in /pr/p1"
		$result[1].CompletionText | Should -Be "P2"
		$result[1].ListItemText | Should -Be "P2"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -Be "Project P2 in /p2"
		$result[2].CompletionText | Should -Be "3"
		$result[2].ListItemText | Should -Be "3"
		$result[2].ResultType | Should -Be "ParameterValue"
		$result[2].ToolTip | Should -Be "Project 3 in /p3"
	}
}
