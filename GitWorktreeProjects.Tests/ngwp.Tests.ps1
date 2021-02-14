Describe "ngwp" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

	It "should be an alias of New-GitWorktreeProject" {

		$alias = Get-Alias ngwp

		$alias.ReferencedCommand | Should -Be "New-GitWorktreeProject"
	}
}
