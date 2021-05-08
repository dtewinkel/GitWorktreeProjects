Describe "Set-GitWorktreeDefaults" {
	BeforeAll {

		. $PSScriptRoot/Helpers/LoadModule.ps1
		. $PSScriptRoot/Helpers/LoadAllModuleFiles.ps1
	}

	BeforeEach {

		$defaultConfig = @{
			DefaultRootPath     = '/root'
			DefaultSourceBranch = 'origin'
			DefaultTools        = @( '1', 'a')
		}

		Mock GetGlobalConfig { $defaultConfig } -Verifiable
		Mock SetGlobalConfig {}

		$expectedConfig = @{
			DefaultRootPath     = '/root'
			DefaultSourceBranch = 'origin'
			DefaultTools        = @( '1', 'a')
		}
	}

	It "should have the right parameters" {

		$command = Get-Command Set-GitWorktreeDefaults
		$command | Should -HaveParameter DefaultRoot
		$command | Should -HaveParameter DefaultBranch
		$command | Should -HaveParameter DefaultTools
	}

	It "should fail with no parameters" {

		{ Set-GitWorktreeDefaults } | Should -Throw "At least either -DefaultRoot, -DefaultBranch, or -DefaultTools must be specified!"
	}

	It "should not update DefaultRoot if does not exist" {

		$expectedDefaultRoot = "/new/root/path"
		$expectedConfig.DefaultRootPath = $expectedDefaultRoot

		Mock Test-Path { $false } -Verifiable -ParameterFilter { $Path -eq $expectedDefaultRoot }
		Mock SetGlobalConfig {}

		{ Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot } | Should -Throw "DefaultRoot '${expectedDefaultRoot}' must exist!"

		Should -InvokeVerifiable
	}

	It "should only update DefaultRoot if that is set and exists" {

		$expectedDefaultRoot = "/new/root/path"
		$expectedConfig.DefaultRootPath = $expectedDefaultRoot

		Mock Test-Path { $true } -Verifiable -ParameterFilter { $Path -eq $expectedDefaultRoot }
		Mock SetGlobalConfig {}

		Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot

		Should -InvokeVerifiable
	}

	It "should only update DefaultBranch if that is set" {

		$expectedBranch = "testing-123"
		$expectedConfig.DefaultSourceBranch = $expectedBranch

		Mock SetGlobalConfig {}

		Set-GitWorktreeDefaults -DefaultBranch $expectedBranch

		Should -InvokeVerifiable
		Should -Invoke SetGlobalConfig -ParameterFilter { & $PSScriptRoot/Helpers/CompareObject.ps1 $GlobalConfig $expectedConfig GlobalConfig -AsBoolean } -Times 1
	}

	It "should only update DefaultTools if that is set" {

		$expectedTools = "new-tool1", "anothertool"
		$expectedConfig.DefaultTools = $expectedTools

		Set-GitWorktreeDefaults -DefaultTools $expectedTools

		Should -InvokeVerifiable
		Should -Invoke SetGlobalConfig -ParameterFilter { & $PSScriptRoot/Helpers/CompareObject.ps1 $GlobalConfig $expectedConfig GlobalConfig -AsBoolean } -Times 1
	}

	It "should update all if all are set" {

		$expectedDefaultRoot = "/new/root/path"
		$expectedBranch = "testing-123"
		$expectedTools = "some-tool1", "anothertool"
		$expectedConfig.DefaultRootPath = $expectedDefaultRoot
		$expectedConfig.DefaultSourceBranch = $expectedBranch
		$expectedConfig.DefaultTools = $expectedTools

		Mock Test-Path { $true } -Verifiable -ParameterFilter { $Path -eq $expectedDefaultRoot }

		Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch -DefaultTools $expectedTools

		Should -InvokeVerifiable
		Should -Invoke SetGlobalConfig -ParameterFilter { & $PSScriptRoot/Helpers/CompareObject.ps1 $GlobalConfig $expectedConfig GlobalConfig -AsBoolean } -Times 1
	}
}
