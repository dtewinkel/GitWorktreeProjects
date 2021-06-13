[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "Get-GitWorktreeDefaults" {

	BeforeAll {
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should use GetGlobalConfig and pass on the results" {

		$configFromFile = @{
			DefaultRootPath     = '/root'
			DefaultSourceBranch = 'origin'
			DefaultTools        = @( '1', 'a')
		}

		Mock GetGlobalConfig { $configFromFile } -Verifiable -ModuleName GitWorktreeProjects

		$config = Get-GitWorktreeDefaults

		$config.DefaultRootPath | Should -Be '/root'
		$config.DefaultSourceBranch | Should -Be 'origin'
		Should -InvokeVerifiable
	}
}
