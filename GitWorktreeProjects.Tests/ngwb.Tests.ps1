Describe "ngwb" {

	It "should be an alias of New-GitWorktreeBranch" {

		. $PSScriptRoot/Helpers/LoadModule.ps1

		$alias = Get-Alias ngwb

		$alias.ReferencedCommand | Should -Be "New-GitWorktreeBranch"
	}
}
