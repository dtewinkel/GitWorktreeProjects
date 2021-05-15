Describe "GlobalConfig" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/BackupGitWorktreeConfigPath.ps1
		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1
	}

	It "Creates a new instance with sensible defaults" -ForEach @(
		@{
			Value = @{
				VarName               = 'USERPROFILE'
				USERPROFILE           = "/path/to/USERPROFILE"
				HOMEDRIVE             = "/HOMEDRIVE"
				HOMEPATH              = "/path/to/HOMEPATH"
				HOME                  = "/path/to/HOME"
				Expected              = "/path/to/USERPROFILE"
			}
		}
		@{
			Value = @{
				VarName               = 'HOMEDRIVE/HOMEPATH'
				USERPROFILE           = $null
				HOMEDRIVE             = "/HOMEDRIVE"
				HOMEPATH              = "/path/to/HOMEPATH"
				HOME                  = "/path/to/HOME"
				Expected              = "/HOMEDRIVE/path/to/HOMEPATH"
			}
		}
		@{
			Value = @{
				VarName               = 'HOME'
				USERPROFILE           = $null
				HOMEDRIVE             = $null
				HOMEPATH              = $null
				HOME                  = "/path/to/HOME"
				Expected              = "/path/to/HOME"
			}
		}
		@{
			Value = @{
				VarName               = 'fall-back'
				USERPROFILE           = $null
				HOMEDRIVE             = $null
				HOMEPATH              = $null
				HOME                  = $null
				Expected              = "/"
			}
		}
	) {

		. $PSScriptRoot/../Helpers/SetGitWorktreeConfigPath.ps1 $_.Value

		$globalConfig = [GlobalConfig]::new()

		$globalConfig.DefaultRootPath | Should -Be $_.Value.Expected
		$globalConfig.DefaultSourceBranch | Should -Be 'main'
		$globalConfig.DefaultTools | Should -HaveCount 1
		$globalConfig.DefaultTools[0] | Should -Be 'WindowTitle'
	}

	It "Can be converted from file contents" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'
		$defaultTools = @("tool1", 'another tool')

		$fileContents = @{
			SchemaVersion = 1
			DefaultRootPath = $defaultRootPath
			DefaultSourceBranch = $defaultSourceBranch
			DefaultTools = $defaultTools
		}

		$globalConfig = [GlobalConfig]::FromFile($fileContents)

		$globalConfig.DefaultRootPath | Should -Be $defaultRootPath
		$globalConfig.DefaultSourceBranch | Should -Be $defaultSourceBranch
		$globalConfig.DefaultTools | Should -HaveCount 2
		$globalConfig.DefaultTools[0] | Should -Be 'tool1'
		$globalConfig.DefaultTools[1] | Should -Be 'another tool'
	}

	It "Can be converted to file contents" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'
		$defaultTools = @("tool1", 'another tool')

		$globalConfig = [GlobalConfig]::new()
		$globalConfig.DefaultRootPath = $defaultRootPath
		$globalConfig.DefaultSourceBranch = $defaultSourceBranch
		$globalConfig.DefaultTools = $defaultTools

		$fileContents = $globalConfig.ToFile()

		$fileContents.SchemaVersion | Should -Be 1
		$fileContents.DefaultRootPath | Should -Be $defaultRootPath
		$fileContents.DefaultSourceBranch | Should -Be $defaultSourceBranch
		$fileContents.DefaultTools | Should -HaveCount 2
		$fileContents.DefaultTools[0] | Should -Be 'tool1'
		$fileContents.DefaultTools[1] | Should -Be 'another tool'
	}

	AfterAll {
		. $PSScriptRoot/../Helpers/RestoreGitWorktreeConfigPath.ps1
	}
}
