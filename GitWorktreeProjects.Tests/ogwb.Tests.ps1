Describe "ogwb" {

	It "should be an alias of Open-GitWorktreeBranch" {

		. $PSScriptRoot/Helpers/LoadModule.ps1

		$alias = Get-Alias ogwb

		$alias.ReferencedCommand | Should -Be "Open-GitWorktreeBranch"
	}
}
