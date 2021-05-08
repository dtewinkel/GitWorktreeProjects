Describe "Get-GitWorktreeDefaults" {

	BeforeAll {

		. $PSScriptRoot/Helpers/LoadModule.ps1
		. $PSScriptRoot/Helpers/LoadAllModuleFiles.ps1
	}

		It "should use GetGlobalConfig and pass on the results" {

			[GlobalConfig]$configFromFile = @{
				DefaultRootPath     = '/root'
				DefaultSourceBranch = 'origin'
				DefaultTools        = @( '1', 'a')
			}
			Mock GetGlobalConfig { $configFromFile } -Verifiable

			$config = Get-GitWorktreeDefaults

			$config.DefaultRootPath | Should -Be '/root'
			$config.DefaultSourceBranch | Should -Be 'origin'
			Should -InvokeVerifiable
		}
}
