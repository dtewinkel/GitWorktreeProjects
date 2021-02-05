BeforeAll {
	Push-Location
	Mock Out-File -RemoveParameterType "Encoding"
	. $PSScriptRoot/Helpers/LoadModule.ps1

	$defaultRootPath = 'c:\myExcelentProjects'
	$defaultBranch = 'greatest'
	$defaultConfiguration = @{
		DefaultRootPath = $defaultRootPath
		DefaultMainBranch = $defaultBranch
	}
}

Describe "Set-GitWorktreeConfig" {

	Context "Without Default configuration" {

		BeforeAll {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfigPath.ps1
			$expectedFile = Join-Path $env:GitWorktreeConfigPath configuration.json
		}

		It "should create the config if it doesn't exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Creating Default configuration." } -Verifiable
			$config = Set-GitWorktreeConfig -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			$config.DefaultRootPath | Should -Be $expectedDefaultRoot
			$config.DefaultMainBranch | Should -Be $expectedBranch
			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should fail if DefaultRoot does not exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Creating Default configuration." } -Verifiable
			{
				Set-GitWorktreeConfig -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			} | Should -Throw
			Should -InvokeVerifiable
		}

		It "should get existing Configuration" {

			$mockedContent = "mock"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile }
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent }
			$config = Set-GitWorktreeConfig
			$config.DefaultRootPath | Should -Be $defaultRootPath
			$config.DefaultMainBranch | Should -Be $defaultBranch
			Should -InvokeVerifiable
		}

		AfterAll {
			. $PSScriptRoot/Helpers/ResetGitWorktreeConfigPath.ps1
		}
	}

	Context "With Default configuration" {

		BeforeAll {
			. $PSScriptRoot/Helpers/SetGitWorktreeConfigPath.ps1
			Remove-Item env:GitWorktreeConfigPath
			$expectedFile = Join-Path $Home '.gitworktree' configuration.json
		}

		It "should create the config if it doesn't exist" {
			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Creating Default configuration." } -Verifiable
			$config = Set-GitWorktreeConfig -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			$config.DefaultRootPath | Should -Be $expectedDefaultRoot
			$config.DefaultMainBranch | Should -Be $expectedBranch
			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should fail if DefaultRoot does not exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Creating Default configuration." } -Verifiable
			{
				Set-GitWorktreeConfig -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			} | Should -Throw
			Should -InvokeVerifiable
		}

		It "should get existing Configuration" {

			$mockedContent = "mock"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile }
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent }
			$config = Set-GitWorktreeConfig
			$config.DefaultRootPath | Should -Be $defaultRootPath
			$config.DefaultMainBranch | Should -Be $defaultBranch
			Should -InvokeVerifiable
		}

		AfterAll {
			. $PSScriptRoot/Helpers/ResetGitWorktreeConfigPath.ps1
		}
	}
}

AfterAll {
	Pop-Location
}
