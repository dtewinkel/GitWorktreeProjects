[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "ggwp" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should be an alias of Get-GitWorktreeProject" {

		$alias = Get-Alias ggwp

		$alias.ReferencedCommand | Should -Be "Get-GitWorktreeProject"
	}
}
