[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "ggw" {

	BeforeAll {
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of Get-GitWorktree" {

		$alias = Get-Alias ggw

		$alias.ReferencedCommand | Should -Be "Get-GitWorktree"
	}
}
