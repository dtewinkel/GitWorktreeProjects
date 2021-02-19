BeforeAll {
	Push-Location
	Mock Out-File -RemoveParameterType "Encoding"
	. $PSScriptRoot/Helpers/LoadModule.ps1

	$mockedContent = "{dummy}"
	$defaultRootPath = 'c:\myExcelentProjects'
	$defaultSourceBranch = 'greatest'
	$defaultConfiguration = @{
		DefaultRootPath = $defaultRootPath
		DefaultSourceBranch = $defaultSourceBranch
	}
}

Describe "Set-GitWorktreeDefaults" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeAll {
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

		It "should create the config if it doesn't exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-1"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Using Default configuration." } -Verifiable
			$config = Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			$config.DefaultRootPath | Should -Be $expectedDefaultRoot
			$config.DefaultSourceBranch | Should -Be $expectedBranch
			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should update the config if it exists" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-1"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent } -Verifiable
			$config = Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			Should -InvokeVerifiable
			$config.DefaultRootPath | Should -Be $expectedDefaultRoot
			$config.DefaultSourceBranch | Should -Be $expectedBranch
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should only update DefaultRoot if that is set" {

			$expectedDefaultRoot = "${TestDrive}"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent } -Verifiable
			$config = Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot
			Should -InvokeVerifiable
			$config.DefaultRootPath | Should -Be $expectedDefaultRoot
			$config.DefaultSourceBranch | Should -Be $defaultSourceBranch
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should only update DefaultBranch if that is set" {

			$expectedBranch = "testing-1"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Get-Content { $mockedContent } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock ConvertFrom-Json { $defaultConfiguration } -ParameterFilter { $InputObject -eq $mockedContent } -Verifiable
			$config = Set-GitWorktreeDefaults -DefaultBranch $expectedBranch
			Should -InvokeVerifiable
			$config.DefaultRootPath | Should -Be $defaultRootPath
			$config.DefaultSourceBranch | Should -Be $expectedBranch
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" }
		}

		It "should fail if DefaultRoot does not exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-2"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -eq "Using Default configuration." } -Verifiable
			{
				Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch
			} | Should -Throw "DefaultRoot '${TestDrive}' must exist!"
			Should -InvokeVerifiable
		}
	}

	Context "With any configuration" {
		It "should fail with no parameters" {

			{ Set-GitWorktreeDefaults } | Should -Throw "At least either -DefaultRoot or -DefaultBranch must be specified!"
		}

		AfterAll {
			. $PSScriptRoot/Helpers/ResetGitWorktreeConfigPath.ps1
		}
	}
}

AfterAll {
	Pop-Location
}
