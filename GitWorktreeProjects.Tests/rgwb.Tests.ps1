Describe "rgwb" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of Remove-GitWorktreeBranch" {

		$alias = Get-Alias rgwb

		$alias.ReferencedCommand | Should -Be "Remove-GitWorktreeBranch"
	}
}
