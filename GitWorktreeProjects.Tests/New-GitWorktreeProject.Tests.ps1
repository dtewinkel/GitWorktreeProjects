[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "New-GitWorktreeProject" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command New-GitWorktreeProject

		$command | Should -HaveParameter Project -Mandatory
		$command | Should -HaveParameter Repository -Mandatory
		$command | Should -HaveParameter TargetPath
		$command | Should -HaveParameter SourceBranch
		$command | Should -HaveParameter Force
	}
}
