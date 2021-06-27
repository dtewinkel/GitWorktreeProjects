[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "Get-GitWorktree" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktree

		$command | Should -HaveParameter WorktreeFilter -HasArgumentCompleter
		$command | Should -HaveParameter Project -HasArgumentCompleter
	}
}
