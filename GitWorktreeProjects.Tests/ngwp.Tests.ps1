[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "ngwp" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of New-GitWorktreeProject" {

		$alias = Get-Alias ngwp

		$alias.ReferencedCommand | Should -Be "New-GitWorktreeProject"
	}
}
