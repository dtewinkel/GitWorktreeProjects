BeforeAll {
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
}

Describe "Get-GitWorktreeProject" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeEach {
			$config = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "OneProject"
		}

		It "should get project information from the right location" {

			$result = Get-GitWorktreeProject MyFirstProject
			
			. $PSScriptRoot/Helpers/CompareProject.ps1 -Actual $result -Expected $config.Projects.MyFirstProject.Project
		}

		It "Should return information about all projects if called without parameters" {
			$result = Get-GitWorktreeProject MyFirstProject

			. $PSScriptRoot/Helpers/CompareProject.ps1 -Actual $result -Expected $config.Projects.MyFirstProject.Project
		}

		It "Should return information about all projects if called without parameters" {
		}
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
}
