BeforeAll {
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
}

Describe "Get-GitWorktreeProject" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeEach {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "ThreeProjects"
		}

		It "should get project information for a specific project" {
			$ProjectName = "SecondProject"

			$result = Get-GitWorktreeProject -ProjectFilter $ProjectName

			. $PSScriptRoot/Helpers/CompareProject.ps1 -Actual $result -Expected $testConfig.Projects.${ProjectName}.Project
		}

		It "Should return information about all projects if called without parameters" {

			$result = Get-GitWorktreeProject

			. $PSScriptRoot/Helpers/CompareProject.ps1 -Actual $result -Expected $testConfig.Projects.Values.Project -ExpectedType "Project[]"
		}

		It "Should return information about the current project" {

			$ProjectName = "SecondProject"

			$project = $testConfig.Projects.${ProjectName}.Project
			Mock Get-Location { @{ Path = $project.RootPath } } -Verifiable

			$result = Get-GitWorktreeProject -ProjectFilter .

			Should -InvokeVerifiable
			. $PSScriptRoot/Helpers/CompareProject.ps1 -Actual $result -Expected $project
		}

		It "Should fail if outside a project for the current project" {

			Mock Get-Location { @{ Path = "dummy" } } -Verifiable

			{
				Get-GitWorktreeProject -ProjectFilter .
			} | Should -Throw "Could not determine the Project in the current directory."

			Should -InvokeVerifiable
		}
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
}
