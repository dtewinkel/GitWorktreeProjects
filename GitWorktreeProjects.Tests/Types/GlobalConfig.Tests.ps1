[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "GlobalConfig" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "Creates a new instance with sensible defaults for <VarName>" -ForEach @(
		@{
			VarName      = 'USERPROFILE'
			_USERPROFILE = "/path/to/USERPROFILE"
			_HOMEDRIVE   = "/HOMEDRIVE"
			_HOMEPATH    = "/path/to/HOMEPATH"
			_HOME        = "/path/to/HOME"
			Expected     = "/path/to/USERPROFILE"
		}
		@{
			VarName      = 'HOMEDRIVE/HOMEPATH'
			_USERPROFILE = $null
			_HOMEDRIVE   = "/HOMEDRIVE"
			_HOMEPATH    = "/path/to/HOMEPATH"
			_HOME        = "/path/to/HOME"
			Expected     = "/HOMEDRIVE/path/to/HOMEPATH"
		}
		@{
			VarName      = 'HOME'
			_USERPROFILE = $null
			_HOMEDRIVE   = $null
			_HOMEPATH    = $null
			_HOME        = "/path/to/HOME"
			Expected     = "/path/to/HOME"
		}
		@{
			VarName      = 'fall-back'
			_USERPROFILE = $null
			_HOMEDRIVE   = $null
			_HOMEPATH    = $null
			_HOME        = $null
			Expected     = "/"
		}
	) {

		function MockEnvironmentVariable($name, $value)
		{
			$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq 'Env:${name}'")
			$resultScriptBlock = [Scriptblock]::Create("@{ Value = '$value' }")
			Mock Get-Item $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock
		}

		MockEnvironmentVariable 'USERPROFILE' $_USERPROFILE
		MockEnvironmentVariable 'HOMEDRIVE' $_HOMEDRIVE
		MockEnvironmentVariable 'HOMEPATH' $_HOMEPATH
		MockEnvironmentVariable 'HOME' $_HOME

		$globalConfig = [GlobalConfig]::new()

		$globalConfig.DefaultRootPath | Should -Be $Expected
		$globalConfig.DefaultSourceBranch | Should -Be 'main'
		$globalConfig.DefaultTools | Should -HaveCount 1
		$globalConfig.DefaultTools[0] | Should -Be 'WindowTitle'
	}

	It "Can be converted from file contents" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'
		$defaultTools = @("tool1", 'another tool')

		$fileContents = @{
			SchemaVersion       = 1
			DefaultRootPath     = $defaultRootPath
			DefaultSourceBranch = $defaultSourceBranch
			DefaultTools        = $defaultTools
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
}
