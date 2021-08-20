[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "ValidateGit" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder

	}

	It "should throw exception if git is not found" {

		Mock Get-Command {  } -ParameterFilter { $Name -eq 'git' } -Verifiable

		{ ValidateGit } | Should -Throw ""

		Should -InvokeVerifiable
	}

	It "should not throw exception if git is found" {

		Mock Get-Command { @{} } -ParameterFilter { $Name -eq 'git' } -Verifiable

		{ ValidateGit } | Should -Not -Throw

		Should -InvokeVerifiable
	}
}
