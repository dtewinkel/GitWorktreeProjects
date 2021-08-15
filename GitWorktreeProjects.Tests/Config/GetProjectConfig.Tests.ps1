[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder
)

Describe "GetProjectConfig" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder

		$projectName = "Testing123"
		$worktrees = @(
			@{
				Name = "Test123"
			}
			@{
				Name = "Demo123"
			}
		)

		$fileContents = @{
			SchemaVersion = 1
			Name          = $projectName
			Worktrees     = $worktrees
		}

	}

	It "Should throw if GetConfigFile throws" {

		Mock GetCurrentProject { throw "Oops!" } -Verifiable

		{ GetProjectConfig . } | Should -Throw "Oops!"

		Should -InvokeVerifiable
	}

	It "Should return nothing if current project cannot be found and -FailOnMissing is not given" {

		Mock GetCurrentProject { } -Verifiable

		$projectConfig = GetProjectConfig .

		Should -InvokeVerifiable
		$projectConfig | Should -BeNullOrEmpty
	}

	It "Should fail if current project cannot be found and -FailOnMissing is given" {

		Mock GetCurrentProject { } -Verifiable

		{ GetProjectConfig . -FailOnMissing } | Should -Throw "Could not determine the Project in the current directory."

		Should -InvokeVerifiable
	}

	It "Should fail if current project cannot be found and -FailOnMissing is given" {

		Mock GetCurrentProject { } -Verifiable

		{ GetProjectConfig -Project . -FailOnMissing } | Should -Throw "Could not determine the Project in the current directory."

		Should -InvokeVerifiable
	}

	It "Should fail if project file cannot be found for current project and -FailOnMissing is given" {

		$projectName = "Testing123"
		Mock GetCurrentProject { $projectName } -Verifiable
		Mock GetConfigFile { } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		{ GetProjectConfig . -FailOnMissing } | Should -Throw "Project Config File '${projectName}.project' for project '${projectName}' not found!*"

		Should -InvokeVerifiable
	}

	It "Should fail if project file cannot be found for current project and -FailOnMissing is given" {

		Mock GetCurrentProject { $projectName } -Verifiable
		Mock GetConfigFile { } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$projectConfig = GetProjectConfig .

		Should -InvokeVerifiable
		$projectConfig | Should -BeNullOrEmpty
	}

	It "Should fail if project file cannot be found for given project and -FailOnMissing is given" {

		Mock GetCurrentProject {}
		Mock GetConfigFile { } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		{ GetProjectConfig -Project $projectName -FailOnMissing } | Should -Throw "Project Config File '${projectName}.project' for project '${projectName}' not found!*"

		Should -InvokeVerifiable
		Should -Not -Invoke GetCurrentProject
	}

	It "Should fail if project file cannot be found for given project and -FailOnMissing is given" {

		Mock GetCurrentProject {}
		Mock GetConfigFile { } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$projectConfig = GetProjectConfig -Project $projectName

		Should -InvokeVerifiable
		Should -Not -Invoke GetCurrentProject
		$projectConfig | Should -BeNullOrEmpty
	}

	It "returns config if config file exists" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$config = GetProjectConfig -Project $projectName

		Should -InvokeVerifiable
		$config | Should -Not -BeNullOrEmpty
		$config | Should -Not -BeNullOrEmpty
		$config.Name | Should -Be $projectName
		$config.Worktrees | Should -HaveCount 2
		$config.Worktrees[0].Name | Should -Be "Test123"
		$config.Worktrees[1].Name | Should -Be "Demo123"

	}

	It "returns config with selected Worktrees if config file exists" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$config = GetProjectConfig -Project $projectName -WorktreeFilter Test*

		Should -InvokeVerifiable
		$config | Should -Not -BeNullOrEmpty
		$config.Name | Should -Be $projectName
		$config.Worktrees | Should -HaveCount 1
		$config.Worktrees[0].Name | Should -Be "Test123"
	}

	It "returns config with selected Worktrees if config file exists" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$config = GetProjectConfig -Project $projectName -WorktreeFilter Test123 -WorktreeExactMatch

		Should -InvokeVerifiable
		$config | Should -Not -BeNullOrEmpty
		$config.Name | Should -Be $projectName
		$config.Worktrees | Should -HaveCount 1
		$config.Worktrees[0].Name | Should -Be "Test123"
	}


	It "returns nothing with selected Worktrees not matching if config file exists" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$config = GetProjectConfig -Project $projectName -WorktreeFilter None*

		Should -InvokeVerifiable
		$config | Should -BeNullOrEmpty
	}

	It "returns nothing when Worktrees not matching if config file exists, and -WorktreeExactMatch" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		$config = GetProjectConfig -Project $projectName -WorktreeFilter Test* -WorktreeExactMatch

		Should -InvokeVerifiable
		$config | Should -BeNullOrEmpty
	}

	It "Fail with selected Worktrees not matching if config file exists, and -WorktreeExactMatch and -FailOnMissing" {

		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq "${projectName}.project" } -Verifiable

		{ GetProjectConfig -Project $projectName -WorktreeFilter None123 -WorktreeExactMatch -FailOnMissing } |
			Should -Throw "Worktree 'None123' for project '${projectName}' not found! Use New-GitWorktree to create it."

		Should -InvokeVerifiable
	}
}
