[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "Remove-GitWorktree" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command Remove-GitWorktree

		$command | Should -HaveParameter Project -Mandatory
		$command | Should -HaveParameter Worktree -Mandatory
		$command | Should -HaveParameter Force
	}
}
