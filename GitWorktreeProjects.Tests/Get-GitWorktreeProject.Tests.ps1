Describe "Get-GitWorktreeProject" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1
		. $PSScriptRoot/Helpers/LoadTypes.ps1
		. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
	}

	It "should have the right parameters" {
		$command = Get-Command Get-GitWorktreeProject

		$command | Should -HaveParameter WorktreeFilter
		$command | Should -HaveParameter ProjectFilter
	}

	Context "with tab expansion" {

		It "should expand for ProjectFilter" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject ${_}"

			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length

			$result.CompletionMatches | Should -HaveCount 3
			$result.CompletionMatches[0].CompletionText | Should -Be "AnotherProject"
		}
		It "should expand for WorktreeFilter should work" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject -ProjectFilter AnotherProject -WorktreeFilter *"

			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length

			$result.CompletionMatches | Should -HaveCount 3
			$result.CompletionMatches[0].CompletionText | Should -Be "main"
		}
	}

	It "should get project information for the current project if project names start with the same text" {

		$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup "SimilarProjects"
		$ProjectName = "OneTwo"

		$project = $testConfig.Projects.${ProjectName}.Project
		Mock Get-Location { @{ Path = $project.RootPath } } -Verifiable

		$result = Get-GitWorktreeProject -ProjectFilter .

		. $PSScriptRoot/Helpers/AssertObject.ps1 -Actual $result -Expected $testConfig.Projects.${ProjectName}.Project -ExpectedType "Project"
	}

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeEach {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "ThreeProjects"
		}

		It "should get project information for a specific project" {
			$ProjectName = "SecondProject"

			$result = Get-GitWorktreeProject -ProjectFilter $ProjectName

			. $PSScriptRoot/Helpers/AssertObject.ps1 -Actual $result -Expected $testConfig.Projects.${ProjectName}.Project -ExpectedType "Project"
		}

		It "Should return information about all projects if called without parameters" {

			$result = Get-GitWorktreeProject

			. $PSScriptRoot/Helpers/AssertObject.ps1 -Actual $result -Expected $testConfig.Projects.Values.Project -ExpectedType "Project[]"
		}

		It "Should return information about the current project" {

			$ProjectName = "SecondProject"

			$project = $testConfig.Projects.${ProjectName}.Project
			Mock Get-Location { @{ Path = $project.RootPath } } -Verifiable

			$result = Get-GitWorktreeProject -ProjectFilter .

			Should -InvokeVerifiable
			. $PSScriptRoot/Helpers/AssertObject.ps1 -Actual $result -Expected $project -ExpectedType "Project"
		}

	}

	It "Should fail for path <_> outside a project for the current project" -ForEach @(
		"/root/"
		"C:\Windows\"
	) {

		. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
		Mock Get-Location { @{ Path = $_ } } -Verifiable

		{
			Get-GitWorktreeProject -ProjectFilter .
		} | Should -Throw "Could not determine the Project in the current directory."

		Should -InvokeVerifiable
	}

	AfterAll {
		. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
		Pop-Location
	}
}
