[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

function git()
{
}

Describe "InvokeGit" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should throw exception if git is not found" {

		Mock Get-Command {  } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable

		{ InvokeGit } | Should -Throw "git not found! Please make sure git is installed and can be found."

		Should -InvokeVerifiable
	}

	It "should not throw exception if git is found" {

		Mock Get-Command { @{ Path = 'git' } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable

		{ InvokeGit } | Should -Not -Throw

		Should -InvokeVerifiable
	}

	It "should set git script variabele if git is found" {

		$script:git = $null
		$gitPath = 'git'
		$gitResponse = "yes!"
		Mock git { $gitResponse }
		Mock Get-Command { @{ Path = $gitPath } } -ParameterFilter { $Name -eq 'git' -and $CommandType -eq 'Application' } -Verifiable

		$result = InvokeGit

		$script:git | Should -Be $gitPath

		$result | Should -Be $gitResponse
		Should -InvokeVerifiable
	}

	It "should pass parameters to InvokeGitCmd" {

		$parameters = 'test', 123
		Mock git {}
		$gitcmd = 'git'
		$script:git = $gitcmd

		InvokeGit @parameters

		Should -Invoke git -ParameterFilter { $args.Length -eq $parameters.Length -and $args[0] -eq $parameters[0] -and $args[1] -eq $parameters[1] }
	}

	It "return output if InvokeGitCmd succeeds" {

		$parameters = 'test', 123
		Mock git { $parameters }
		$gitcmd = 'git'
		$script:git = $gitcmd

		$result = InvokeGit @parameters

		$result | Should -Match "^test`n123$"
	}

	It "should throw exception if git fails" {

		Mock git { throw "oops" }
		$gitcmd = 'git'
		$script:git = $gitcmd

		{ InvokeGit } | Should -Throw "oops"
	}

	It "should throw exception if git fails with ErrorRecord" {

		Mock git { Write-Error "oops" }
		$gitcmd = 'git'
		$script:git = $gitcmd

		{ InvokeGit } | Should -Throw "oops"
	}
}
