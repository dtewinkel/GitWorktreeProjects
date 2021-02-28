BeforeAll {
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
	$object = @{
		Name = "Truus"
		Age = 55
	 }
}

Describe "Get-GitWorktreeProject" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeEach {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "OneProject"
		}

		It "should get project information from the right location" {

			$result = Get-GitWorktreeProject MyFirstProject
			Should -InvokeVerifiable
		}
	}

	It "Should return information about all projects if called without parameters" {
	}

	It "Should return information about all projects if called without parameters" {
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
}
