[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "New-GitWorktree" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command New-GitWorktree

		$command | Should -HaveParameter Project -Mandatory
		$command | Should -HaveParameter Commitish
		$command | Should -HaveParameter NewBranch
		$command | Should -HaveParameter Name
		$command | Should -HaveParameter Path
	}
}
