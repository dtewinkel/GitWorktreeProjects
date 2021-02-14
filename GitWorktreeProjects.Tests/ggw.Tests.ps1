Describe "ggw" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of Get-GitWorktree" {

		$alias = Get-Alias ggw

		$alias.ReferencedCommand | Should -Be "Get-GitWorktree"
	}
}
