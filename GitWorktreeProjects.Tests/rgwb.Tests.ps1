Describe "rgwb" {

	It "should be an alias of Remove-GitWorktreeBranch" {

		. $PSScriptRoot/Helpers/LoadModule.ps1

		$alias = Get-Alias rgwb

		$alias.ReferencedCommand | Should -Be "Remove-GitWorktreeBranch"
	}
}
