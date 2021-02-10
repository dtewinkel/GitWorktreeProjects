Describe "ogw" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of Open-GitWorktree" {

		$alias = Get-Alias ogw

		$alias.ReferencedCommand | Should -Be "Open-GitWorktree"
	}
}
