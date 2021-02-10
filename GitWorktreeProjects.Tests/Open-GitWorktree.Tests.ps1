
BeforeAll {
	Push-Location
	. $PSScriptRoot/Helpers/LoadModule.ps1
	. $PSScriptRoot/Helpers/SetGitWorktreeConfigPath.ps1
}

Describe "Open-GitWorktree" {

	It "should fail if project does not exist" {
		{
			Open-GitWorktree -Project NonExisting -WorkTree None
		} | Should -Throw "Project config File '*Nonexisting.project' for project 'Nonexisting' not found!*"
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/ResetGitWorktreeConfigPath.ps1
	Pop-Location
}
