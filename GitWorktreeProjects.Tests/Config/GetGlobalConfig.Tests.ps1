Describe "GetGlobalConfig" {

	BeforeAll {

		$defaultEnv = @{
			Value = @{
				VarName     = 'fall-back'
				USERPROFILE = $null
				HOMEDRIVE   = $null
				HOMEPATH    = $null
				HOME        = $null
				Expected    = "/"
			}
		}

		. $PSScriptRoot/../Helpers/BackupGitWorktreeConfigPath.ps1
		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfigPath.ps1 $defaultEnv
	}

	It "should throw if GetConfigFile throws" {

		Mock GetConfigFile { throw "Oops!" }
		{ GetGlobalConfig } | Should -Throw "Oops!"
	}

	It "returns default config if config file does not exist" {

		Mock GetConfigFile { $null } -ParameterFilter { $FileName -eq 'configuration.json' } -Verifiable
		Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable

		$globalConfig = GetGlobalConfig

		Should -InvokeVerifiable
		$globalConfig | Should -Not -BeNullOrEmpty
		$globalConfig.DefaultRootPath | Should -Be '/'
		$globalConfig.DefaultSourceBranch | Should -Be 'main'
		$globalConfig.DefaultTools | Should -HaveCount 1
		$globalConfig.DefaultTools[0] | Should -Be 'WindowTitle'

	}

	It "returns config if config file exists" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'
		$defaultTools = @("tool1", 'another tool')

		$fileContents = @{
			SchemaVersion       = 1
			DefaultRootPath     = $defaultRootPath
			DefaultSourceBranch = $defaultSourceBranch
			DefaultTools        = $defaultTools
		}
		Mock GetConfigFile { $fileContents } -ParameterFilter { $FileName -eq 'configuration.json' } -Verifiable

		$globalConfig = GetGlobalConfig

		Should -InvokeVerifiable
		$globalConfig | Should -Not -BeNullOrEmpty
		$globalConfig.DefaultRootPath | Should -Be $defaultRootPath
		$globalConfig.DefaultSourceBranch | Should -Be $defaultSourceBranch
		$globalConfig.DefaultTools | Should -HaveCount 2
		$globalConfig.DefaultTools[0] | Should -Be 'tool1'
		$globalConfig.DefaultTools[1] | Should -Be 'another tool'
	}

	AfterAll {
		. $PSScriptRoot/../Helpers/RestoreGitWorktreeConfigPath.ps1
	}
}
