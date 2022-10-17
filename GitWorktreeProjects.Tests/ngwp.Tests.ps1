[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "ngwp" {

	BeforeAll {
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of New-GitWorktreeProject" {

		$alias = Get-Alias ngwp

		$alias.ReferencedCommand | Should -Be "New-GitWorktreeProject"
	}
}
