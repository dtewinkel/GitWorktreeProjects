[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

$getConfigFilePathCombinations = @(
	@{
		VarName                = 'GitWorktreeConfigPath'
		_GitWorktreeConfigPath = "/path/to/GitWorktreeConfigPath"
		_USERPROFILE           = "/path/to/USERPROFILE"
		_HOMEDRIVE             = "/HOMEDRIVE"
		_HOMEPATH              = "/path/to/HOMEPATH"
		_HOME                  = "/path/to/HOME"
		Expected               = "/path/to/GitWorktreeConfigPath"
	}
	@{
		VarName                = 'USERPROFILE'
		_GitWorktreeConfigPath = $null
		_USERPROFILE           = "/path/to/USERPROFILE"
		_HOMEDRIVE             = "/HOMEDRIVE"
		_HOMEPATH              = "/path/to/HOMEPATH"
		_HOME                  = "/path/to/HOME"
		Expected               = "/path/to/USERPROFILE/.gitworktree"
	}
	@{
		VarName                = 'HOMEDRIVE/HOMEPATH'
		_GitWorktreeConfigPath = $null
		_USERPROFILE           = $null
		_HOMEDRIVE             = "/HOMEDRIVE"
		_HOMEPATH              = "/path/to/HOMEPATH"
		_HOME                  = "/path/to/HOME"
		Expected               = "/HOMEDRIVE/path/to/HOMEPATH/.gitworktree"
	}
	@{
		VarName                = 'HOME'
		_GitWorktreeConfigPath = $null
		_USERPROFILE           = $null
		_HOMEDRIVE             = $null
		_HOMEPATH              = $null
		_HOME                  = "/path/to/HOME"
		Expected               = "/path/to/HOME/.gitworktree"
	}
)

Describe "GetConfigFilePath" {

	BeforeAll {

		function MockEnvironmentVariable($name, $value)
		{
			$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq 'Env:${name}'")
			$resultScriptBlock = [Scriptblock]::Create("@{ Value = '$value' }")
			Mock Get-Item $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock
		}

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command GetConfigFilePath
		$command | Should -HaveParameter ChildPath
	}

	It "should throw if path cannot be determined" {

		MockEnvironmentVariable 'GitWorktreeConfigPath' $null
		MockEnvironmentVariable 'USERPROFILE' $null
		MockEnvironmentVariable 'HOMEDRIVE' $null
		MockEnvironmentVariable 'HOMEPATH' $null
		MockEnvironmentVariable 'HOME' $null

		{ GetConfigFilePath } | Should -Throw "Cannot determine location of GitWorktreeProject configuration files."
	}

	It "should use the environment variable <VarName>" -ForEach $getConfigFilePathCombinations {

		MockEnvironmentVariable 'GitWorktreeConfigPath' $_GitWorktreeConfigPath
		MockEnvironmentVariable 'USERPROFILE' $_USERPROFILE
		MockEnvironmentVariable 'HOMEDRIVE' $_HOMEDRIVE
		MockEnvironmentVariable 'HOMEPATH' $_HOMEPATH
		MockEnvironmentVariable 'HOME' $_HOME

		$config = GetConfigFilePath

		# replace / with / or \, as returned by the OS.
		$config | Should -Be ($Expected -replace '/', $config[0])
	}

	It "should use the environment variable <VarName> and add ChildPath" -ForEach $getConfigFilePathCombinations {

		MockEnvironmentVariable 'GitWorktreeConfigPath' $_GitWorktreeConfigPath
		MockEnvironmentVariable 'USERPROFILE' $_USERPROFILE
		MockEnvironmentVariable 'HOMEDRIVE' $_HOMEDRIVE
		MockEnvironmentVariable 'HOMEPATH' $_HOMEPATH
		MockEnvironmentVariable 'HOME' $_HOME
		$childPath = '*.ps1'

		$config = GetConfigFilePath -ChildPath $childPath

		# replace / with / or \, as returned by the OS.
		$expectedPath = Join-Path $Expected $childPath
		$config | Should -Be $expectedPath
	}
}
