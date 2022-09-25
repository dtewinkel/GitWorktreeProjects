[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "InvokeGit" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder

		$gitCommand = 'path-to-git'
		$defaultGitResult = [PSCustomObject]@{
			ExitCode = 0
		}
	}

	It "should throw exception if git is not found" {

		Mock Get-Command {  } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable

		{ InvokeGit } | Should -Throw "git not found! Please make sure git is installed and can be found."

		Should -InvokeVerifiable
	}

	It "should not throw exception if git is found" {

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru } -Verifiable

		{ InvokeGit } | Should -Not -Throw

		Should -InvokeVerifiable
	}

	It "should find Git and invoke it" {

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru } -Verifiable

		$result = InvokeGit

		Should -InvokeVerifiable

		$result.GitExecutable | Should -Be $gitCommand
	}

	It "should pass parameters to git invocation" {

		$parameters = 'test', 123, '-v'

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru }

		InvokeGit @parameters

		Should -Invoke Start-Process -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru `
			-and $ArgumentList.Length -eq $ArgumentList.Length -and $parameters[0] -eq $parameters[0] -and $ArgumentList[1] -eq $parameters[1] -and $ArgumentList[2] -eq $parameters[2] }
	}

	It "return stdout output from git invocation" {

		$parameters = 'test', 123
		$script:stdOutFile = $null
		$script:stdErrFile = $null
		$stdOutFileText = "from stdout!"

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $script:stdOutFile = $PesterBoundParameters.RedirectStandardOutput; $script:stdErrFile = $PesterBoundParameters.RedirectStandardError; $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $script:stdOutFile } -Verifiable
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $script:stdErrFile } -Verifiable
		Mock Remove-Item { } -ParameterFilter { $Path -eq $script:stdOutFile } -Verifiable
		Mock Get-Content { $stdOutFileText } -ParameterFilter { $Path -eq $script:stdOutFile -and $Raw } -Verifiable

		$result = InvokeGit @parameters

		Should -InvokeVerifiable

		$result.OutputText  | Should -Be $stdOutFileText
		$result.ErrorText  | Should -BeNull
	}

	It "return stderr output from git invocation" {

		$parameters = 'test', 123
		$script:stdOutFile = $null
		$script:stdErrFile = $null
		$stdErrFileText = "from stderr!"

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $script:stdOutFile = $PesterBoundParameters.RedirectStandardOutput; $script:stdErrFile = $PesterBoundParameters.RedirectStandardError; $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru } -Verifiable
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $script:stdOutFile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $script:stdErrFile } -Verifiable
		Mock Remove-Item { } -ParameterFilter { $Path -eq $script:stdErrFile } -Verifiable
		Mock Get-Content { $stdErrFileText } -ParameterFilter { $Path -eq $script:stdErrFile -and $Raw } -Verifiable

		$result = InvokeGit @parameters

		Should -InvokeVerifiable

		$result.OutputText | Should -BeNull
		$result.ErrorText | Should -Be $stdErrFileText
	}

	It "return errorcode from git invocation" {

		$parameters = 'test', 123
		$script:stdOutFile = $null
		$script:stdErrFile = $null
		$stdErrFileText = "from stderr!"

		Mock Get-Command { @{ Path = $gitCommand } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable
		Mock Start-Process { $script:stdOutFile = $PesterBoundParameters.RedirectStandardOutput; $script:stdErrFile = $PesterBoundParameters.RedirectStandardError; $defaultGitResult } -ParameterFilter { $FilePath -eq $gitCommand -and $Wait -and $NoNewWindow -and $PassThru } -Verifiable
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $script:stdOutFile } -Verifiable
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $script:stdErrFile } -Verifiable
		Mock Remove-Item { } -ParameterFilter { $Path -eq $script:stdErrFile } -Verifiable
		Mock Get-Content { $stdErrFileText } -ParameterFilter { $Path -eq $script:stdErrFile -and $Raw } -Verifiable

		$result = InvokeGit @parameters

		Should -InvokeVerifiable

		$result.OutputText | Should -BeNull
		$result.ErrorText | Should -Be $stdErrFileText
	}
}
