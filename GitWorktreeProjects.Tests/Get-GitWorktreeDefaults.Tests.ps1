Describe "Get-GitWorktreeDefaults" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1
		. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1
	}

	Context "With <_> configuration" -ForEach 'Default', 'Custom' {

		It "should get default Configuration if the configuration file does not exist" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "Empty"
			Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable
			$config = Get-GitWorktreeDefaults
			$config.DefaultSourceBranch | Should -Be 'main'
			$config.DefaultRootPath | Should -Be $HOME
			$config.DefaultTools.Length | Should -Be 1
			$config.DefaultTools[0] | Should -Be "WindowTitle"
			Should -InvokeVerifiable
		}

		It "should get existing Configuration" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjects"
			$config = Get-GitWorktreeDefaults
			$config.DefaultRootPath | Should -Be '/projects/0/'
			$config.DefaultSourceBranch | Should -Be 'main0'
			Should -InvokeVerifiable
		}

		It "should fail if config file has corrupt JSON" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsCorruptedJson"
			{ Get-GitWorktreeDefaults } | Should -Throw "Could not convert file 'configuration.json' (*configuration.json)! Is it valid JSON?"
		}

		It "should fail if config file has wrong version" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsWrongVersion"
			{ Get-GitWorktreeDefaults } | Should -Throw "Schema version '0' is not supported for file 'configuration.json' (*configuration.json)."
		}

		It "should fail if config file has no version" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsNoVersion"
			{ Get-GitWorktreeDefaults } | Should -Throw "Schema version is not set for file 'configuration.json' (*configuration.json)."
		}
	}

	AfterAll {
		. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
		Pop-Location
	}
}
