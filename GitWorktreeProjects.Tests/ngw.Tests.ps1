Describe "ngw" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of New-GitWorktree" {

		$alias = Get-Alias ngw

		$alias.ReferencedCommand | Should -Be "New-GitWorktree"
	}
}
