Describe "Get-GitWorktreeDefaults" {

	BeforeAll {

		. $PSScriptRoot/Helpers/LoadAllModuleFiles.ps1
		. $PSScriptRoot/Helpers/LoadModule.ps1
	}

		It "should use GetGlobalConfig ad pass on the results" {

			Mock GetGlobalConfig { @{ DefaultRootPath = '/yes' } } -Verifiable

			$config = Get-GitWorktreeDefaults

			$config.DefaultRootPath | Should -Be '/yes'
			Should -InvokeVerifiable
		}
}
