Describe "ggwp" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of Get-GitWorktreeProject" {

		$alias = Get-Alias ggwp

		$alias.ReferencedCommand | Should -Be "Get-GitWorktreeProject"
	}
}
