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

	Context "with tab expansion for ProjectFilter " -Foreach '', '-ProjectFilter ' {

		It "should expand ProjectFilter to nothing when no projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
			$cmd = "Get-GitWorktreeProject ${_}"
			{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
		}

		It "should expand ProjectFilter to nothing with 3 projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject ${_}"
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 3
			$result.CompletionMatches[0].CompletionText | Should -Be "AnotherProject"
			$result.CompletionMatches[1].CompletionText | Should -Be "MyFirstProject"
			$result.CompletionMatches[2].CompletionText | Should -Be "SecondProject"
		}

		It "should expand ProjectFilter to nothing with 3 projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject ${_}Se"
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 1
			$result.CompletionMatches[0].CompletionText | Should -Be "SecondProject"
		}
	}

	Context "with tab expansion for WorktreeFilter " {

		It "should expand WorktreeFilter to nothing when no projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
			$cmd = "Get-GitWorktreeProject -WorktreeFilter *"
			{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
		}
	}

	Context "with tab expansion for WorktreeFilter" {

		It "should expand WorktreeFilter to nothing when no projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup NoProjects
			$cmd = "Get-GitWorktreeProject -ProjectFilter * -WorktreeFilter "
			{ TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length } | Should -Throw
		}

		It "should expand ProjectFilter to nothing with 3 projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject "
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 3
			$result.CompletionMatches[0].CompletionText | Should -Be "AnotherProject"
			$result.CompletionMatches[1].CompletionText | Should -Be "MyFirstProject"
			$result.CompletionMatches[2].CompletionText | Should -Be "SecondProject"
		}

		It "should expand ProjectFilter to nothing with 3 projects" {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope Custom -Setup ThreeProjects
			$cmd = "Get-GitWorktreeProject Se"
			$result = TabExpansion2 -inputScript $cmd -cursorColumn $cmd.Length
			$result.CompletionMatches | Should -HaveCount 1
			$result.CompletionMatches[0].CompletionText | Should -Be "SecondProject"
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

	Context "With <_> configuration" -Foreach 'Custom', 'Default' {

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

