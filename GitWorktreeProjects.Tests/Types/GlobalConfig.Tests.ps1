[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "GlobalConfig" {

	BeforeAll {

		. $PSScriptRoot/../TestHelpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "Creates a new instance with sensible defaults for <VarName>" -TestCases @(
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
	}

	It "Can be converted from file contents" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'

		$fileContents = @{
			SchemaVersion       = 1
			DefaultRootPath     = $defaultRootPath
			DefaultSourceBranch = $defaultSourceBranch
		}

		$globalConfig = [GlobalConfig]::FromFile($fileContents)

		$globalConfig.DefaultRootPath | Should -Be $defaultRootPath
		$globalConfig.DefaultSourceBranch | Should -Be $defaultSourceBranch
	}

	It "Can be converted to file contents" {

		$defaultRootPath = '/default/root/path'
		$defaultSourceBranch = '/default/branch'

		$globalConfig = [GlobalConfig]::new()
		$globalConfig.DefaultRootPath = $defaultRootPath
		$globalConfig.DefaultSourceBranch = $defaultSourceBranch

		$fileContents = $globalConfig.ToFile()

		$fileContents.SchemaVersion | Should -Be 1
		$fileContents.DefaultRootPath | Should -Be $defaultRootPath
		$fileContents.DefaultSourceBranch | Should -Be $defaultSourceBranch
	}
}
