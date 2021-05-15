$getConfigFilePathCombinations = @(
	@{
		Value = @{
			VarName               = 'GitWorktreeConfigPath'
			GitWorktreeConfigPath = "/path/to/GitWorktreeConfigPath"
			USERPROFILE           = "/path/to/USERPROFILE"
			HOMEDRIVE             = "/HOMEDRIVE"
			HOMEPATH              = "/path/to/HOMEPATH"
			HOME                  = "/path/to/HOME"
			Expected              = "/path/to/GitWorktreeConfigPath"
		}
	}
	@{
		Value = @{
			VarName               = 'USERPROFILE'
			GitWorktreeConfigPath = $null
			USERPROFILE           = "/path/to/USERPROFILE"
			HOMEDRIVE             = "/HOMEDRIVE"
			HOMEPATH              = "/path/to/HOMEPATH"
			HOME                  = "/path/to/HOME"
			Expected              = "/path/to/USERPROFILE/.gitworktree"
		}
	}
	@{
		Value = @{
			VarName               = 'HOMEDRIVE/HOMEPATH'
			GitWorktreeConfigPath = $null
			USERPROFILE           = $null
			HOMEDRIVE             = "/HOMEDRIVE"
			HOMEPATH              = "/path/to/HOMEPATH"
			HOME                  = "/path/to/HOME"
			Expected              = "/HOMEDRIVE/path/to/HOMEPATH/.gitworktree"
		}
	}
	@{
		Value = @{
			VarName               = 'HOME'
			GitWorktreeConfigPath = $null
			USERPROFILE           = $null
			HOMEDRIVE             = $null
			HOMEPATH              = $null
			HOME                  = "/path/to/HOME"
			Expected              = "/path/to/HOME/.gitworktree"
		}
	}
)

Describe "GetConfigFilePath" {

	BeforeAll {


		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/../Helpers/BackupGitWorktreeConfigPath.ps1
	}

	It "should have the right parameters" {
		$command = Get-Command GetConfigFilePath
		$command | Should -HaveParameter ChildPath
	}

	It "should throw if path cannot be determined" {

		. $PSScriptRoot/../Helpers/SetGitWorktreeConfigPath.ps1 -Values @{}
		{ GetConfigFilePath } | Should -Throw "Cannot determine location of GitWorktreeProject configuration files."
	}

	It "should use the environment variable <Value.VarName>" -ForEach $getConfigFilePathCombinations {

		. $PSScriptRoot/../Helpers/SetGitWorktreeConfigPath.ps1 $_.Value
		$config = GetConfigFilePath

		# replace / with / or \, as returned by the OS.
		$config | Should -Be ($_.Value.Expected -replace '/', $config[0])
	}

	It "should use the environment variable <Value.VarName> and add ChildPath" -ForEach $getConfigFilePathCombinations {

		$childPath = '*.ps1'
		. $PSScriptRoot/../Helpers/SetGitWorktreeConfigPath.ps1 $_.Value
		$config = GetConfigFilePath -ChildPath $childPath

		# replace / with / or \, as returned by the OS.
		$expectedPath = Join-Path $_.Value.Expected $childPath
		$config | Should -Be $expectedPath
	}

	AfterAll {
		. $PSScriptRoot/../Helpers/RestoreGitWorktreeConfigPath.ps1
	}
}
