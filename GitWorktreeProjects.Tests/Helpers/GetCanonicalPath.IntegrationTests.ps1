[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

<#
To run these tests the following conditions must be met:
- Running on Windows
- Existing folder C:\Links with the following links:
  - 'JunctionDir' with a
	- 'SymbolicLink' with a symbolic link to 'F:\'
	- 'VolumeDir' with a Volume mounted to it.
	-

#>

Describe "GetCanonicalPath" -Skip:$true {

	BeforeAll {

		. $PSScriptRoot/../TestHelpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\Links\JunctionDir\AzureCli\GlobalSetCLIVerbosity\.EDITORCONFIG" -ForCompare
		$actual | should -BeExactly "F:\AzureCli\GlobalSetCliVerbosity\.editorconfig"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\JUNCtionDir\AzureCLI\GlobalSetCLIVerbosity\.EDITORCONFIG"
		$actual | should -BeExactly "C:\Links\JunctionDir\AzureCli\GlobalSetCliVerbosity\.editorconfig"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\JUNCtionDir" -ForCompare
		$actual | should -BeExactly "F:\"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\JUNCtionDir\LICENsE.TXT" -ForCompare
		$actual | should -BeExactly "F:\license.txt"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\JUNCtionDir\LICENsE.TXT"
		$actual | should -BeExactly "C:\Links\JunctionDir\license.txt"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\JUNCtionDir"
		$actual | should -BeExactly "C:\Links\JunctionDir"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\SYMBOLICLINK"
		$actual | should -BeExactly "C:\Links\SymbolicLink"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\LinKs\SYMBOLICLINK" -ForCompare
		$actual | should -BeExactly "F:\"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\DAta\bEllo\activationCode.xml" -ForCompare
		$actual | should -BeExactly "C:\data\Bello\activationCode.xml"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "c:\DAta\bEllo\activationCode.xml"
		$actual | should -BeExactly "C:\data\Bello\activationCode.xml"
	}

	It "should compare well" {
		$actual = GetCanonicalPath "C:\Links\file.xml" -ForCompare
		$actual | should -BeExactly "K:\Bello\file.xml"
	}
}
