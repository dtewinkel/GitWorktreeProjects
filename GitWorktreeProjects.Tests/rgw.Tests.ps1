[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "rgw" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of Remove-GitWorktree" {

		$alias = Get-Alias rgw

		$alias.ReferencedCommand | Should -Be "Remove-GitWorktree"
	}
}
