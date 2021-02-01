Describe "ogwb" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of Open-GitWorktreeBranch" {

		$alias = Get-Alias ogwb

		$alias.ReferencedCommand | Should -Be "Open-GitWorktreeBranch"
	}
}
