[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "ngw" {

	BeforeAll {
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of New-GitWorktree" {

		$alias = Get-Alias ngw

		$alias.ReferencedCommand | Should -Be "New-GitWorktree"
	}
}
