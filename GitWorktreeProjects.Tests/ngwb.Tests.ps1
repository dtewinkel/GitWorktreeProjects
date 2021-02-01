Describe "ngwb" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of New-GitWorktreeBranch" {

		$alias = Get-Alias ngwb

		$alias.ReferencedCommand | Should -Be "New-GitWorktreeBranch"
	}
}
