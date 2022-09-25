[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "AssertGitSuccess" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should throw exception if git was not successful" -TestCases @(
		@{ ExitCode = 1; ErrorText = "Some Error Happend!"; OutputText = $null; Expected = "Some Error Happend!" }
		@{ ExitCode = 128; ErrorText = "Some Error Happend!"; OutputText = "Useful infomation?"; Expected = "Some Error Happend!" }
		@{ ExitCode = -1; ErrorText = $null; OutputText = "Useful infomation?"; Expected = "Useful infomation?" }
	) {
		$gitResult = [PSCustomObject]@{
			GitExecutable = "git.cmd"
			Arguments     = '-oops'
			Success       = $false
			ExitCode      = $ExitCode
			OutputText    = $OutputText
			ErrorText     = $ErrorText
		}

		{ AssertGitSuccess -GitResult $gitResult } | Should -Throw -ExpectedMessage "*${ExitCode}*${Expected}*['$($gitResult.GitExecutable)' $($gitResult.Arguments)]"
	}

	It "should return data if git was successful" -TestCases @(
		@{ ErrorText = "Some Error Happend!"; OutputText = $null; Expected = "Some Error Happend!" }
		@{ ErrorText = "Some Error Happend!"; OutputText = "Useful infomation?"; Expected = "Useful infomation?" }
		@{ ErrorText = $null; OutputText = "Useful infomation?"; Expected = "Useful infomation?" }
	) {
		$gitResult = [PSCustomObject]@{
			GitExecutable = "git.cmd"
			Arguments     = '--do --something --great'
			Success       = $true
			ExitCode      = $0
			OutputText    = $OutputText
			ErrorText     = $ErrorText
		}

		$result = AssertGitSuccess -GitResult $gitResult

		$result | Should -Be $Expected
	}
}
