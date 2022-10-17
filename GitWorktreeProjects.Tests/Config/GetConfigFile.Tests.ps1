[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "GetConfigFile" {

	BeforeAll {

		$configPath = 'path/to/config'
		$configfile = 'my.project'
		$configfilePath = 'path/to/config/my.project'

		. $PSScriptRoot/../TestHelpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should throw if path cannot be determined" {

		Mock GetConfigFilePath { throw "Cannot determine location of GitWorktreeProject configuration files." }
		{ GetConfigFile $configfile } | Should -Throw "Cannot determine location of GitWorktreeProject configuration files."
	}

	It "return null if config file does not exist" {

		Mock GetConfigFilePath { $configfilePath } -ParameterFilter { $FileName -eq $configfile } -Verifiable
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $configfilePath } -Verifiable

		$config = GetConfigFile $configfile
		# replace / with / or \, as returned by the OS.
		Should -InvokeVerifiable
		$config | Should -BeNullOrEmpty
	}

	It "should have the right parameters" {
		$command = Get-Command GetConfigFile
		$command | Should -HaveParameter FileName -Mandatory
		$command | Should -HaveParameter SchemaVersion
	}

	It "return the content of the config file if all is well" {

		$text = "With some data"
		$content = @"
		{
			"SchemaVersion": 1,
			"SomeOtherField": "${text}"
		}
"@
		Mock GetConfigFilePath { $configfilePath } -ParameterFilter { $FileName -eq $configfile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configfilePath } -Verifiable
		Mock Get-Content { $content } -ParameterFilter { $Raw -and $Path -eq $configfilePath } -Verifiable

		$config = GetConfigFile $configfile
		# replace / with / or \, as returned by the OS.
		Should -InvokeVerifiable
		$config.SchemaVersion | Should -Be 1
		$config.SomeOtherField | Should -Be $text
	}

	It "Throws exception if content '<_>' is not valid JSON." -TestCases @(
		""
		"Oops"
		"{ `"SchemaVersion`" = 1 }"
	)	{

		Mock GetConfigFilePath { $configfilePath } -ParameterFilter { $FileName -eq $configfile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configfilePath } -Verifiable
		Mock Get-Content { $_ } -ParameterFilter { $Raw -and $Path -eq $configfilePath } -Verifiable

		{ GetConfigFile $configfile } | Should -Throw "Could not convert file '${configfile}' (${configFilePath})! Is it valid JSON?"

		Should -InvokeVerifiable
	}

	It "Throws an exception if schema version '<version>' is not the expected version <expected>" -TestCases @(
		@{ version = 1; expected = 2 }
		@{ version = 2; expected = 1 }
	) {

		$version = $_.version
		$expected = $_.expected
		Mock GetConfigFilePath { $configfilePath } -ParameterFilter { $FileName -eq $configfile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configfilePath } -Verifiable
		Mock Get-Content { "{ `"SchemaVersion`": ${version} }" } -ParameterFilter { $Raw -and $Path -eq $configfilePath } -Verifiable

		{ GetConfigFile $configfile -SchemaVersion $expected } | Should -Throw "Schema version '$version' is not supported for file '${configfile}' (${configFilePath})."

		Should -InvokeVerifiable
	}

	It "Throws an exception if schema version is not set" {

		Mock GetConfigFilePath { $configfilePath } -ParameterFilter { $FileName -eq $configfile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $configfilePath } -Verifiable
		Mock Get-Content { "{ `"Version`": 1 }" } -ParameterFilter { $Raw -and $Path -eq $configfilePath } -Verifiable

		{ GetConfigFile $configfile } | Should -Throw "Schema version is not set for file '${configfile}' (${configFilePath})."

		Should -InvokeVerifiable
	}
}
