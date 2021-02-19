BeforeAll {
	Push-Location
	. $PSScriptRoot/Helpers/LoadModule.ps1

	$defaultRootPath = 'c:\myExcelentProjects'
	$defaultSourceBranch = 'greatest'
	$defaultConfiguration = @{
		DefaultRootPath = $defaultRootPath
		DefaultSourceBranch = $defaultSourceBranch
	}
}

Describe "Get-GitWorktreeDefaults" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeEach {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfigPath.ps1
			if($_ -eq 'Default')
			{
				Remove-Item env:GitWorktreeConfigPath
				$expectedFile = Join-Path $Home '.gitworktree' configuration.json
			}
			else {
				$expectedFile = Join-Path $env:GitWorktreeConfigPath configuration.json
			}
		}

		It "should get default Configuration" {

			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Using Default configuration." } -Verifiable
			$config = Get-GitWorktreeDefaults
			$config.DefaultRootPath | Should -Be $HOME
			$config.DefaultSourceBranch | Should -Be 'main'
			Should -InvokeVerifiable
		}

		It "should get existing Configuration" {

			$mockedContent = "mock"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent } -Verifiable
			$config = Get-GitWorktreeDefaults
			$config.DefaultRootPath | Should -Be $defaultRootPath
			$config.DefaultSourceBranch | Should -Be $defaultSourceBranch
			Should -InvokeVerifiable
		}

		AfterEach {
			. $PSScriptRoot/Helpers/ResetGitWorktreeConfigPath.ps1
		}
	}
}

AfterAll {
	Pop-Location
}
