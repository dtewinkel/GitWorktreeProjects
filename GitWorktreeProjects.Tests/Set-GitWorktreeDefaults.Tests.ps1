BeforeAll {
	Push-Location
	Mock Out-File -RemoveParameterType "Encoding"
	. $PSScriptRoot/Helpers/LoadModule.ps1
	. $PSScriptRoot/Helpers/BackupGitWorktreeConfigPath.ps1

	$newMockedContent = "{new}"
}

Describe "Set-GitWorktreeDefaults" {

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		It "should create the config if it doesn't exist" {

			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup Empty
			$expectedFile = $testConfig.globalConfigFile
			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-1"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable
			Mock ConvertTo-Json { $newMockedContent } -Verifiable -ParameterFilter {
				$inputObject.DefaultRootPath -eq $expectedDefaultRoot `
				-and $inputObject.DefaultSourceBranch -eq $expectedBranch `
				-and $inputObject.SchemaVersion -eq 1
			}

			Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch

			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" -and $inputObject -eq $newMockedContent }
		}


		It "should create the config if the config directory doesn't exist" {

			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup Empty
			$expectedFile = $testConfig.globalConfigFile
			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-1"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $testConfig.configRoot } -Verifiable
			Mock New-Item { "" } -ParameterFilter { $Path -eq $testConfig.configRoot -and $ItemType -eq "Directory" } -Verifiable
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable
			Mock ConvertTo-Json { $newMockedContent } -Verifiable -ParameterFilter {
				$inputObject.DefaultRootPath -eq $expectedDefaultRoot `
				-and $inputObject.DefaultSourceBranch -eq $expectedBranch `
				-and $inputObject.SchemaVersion -eq 1
			}

			Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch

			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" -and $inputObject -eq $newMockedContent }
		}

		It "should fail if config file has corrupt JSON" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsCorruptedJson"
			{
				Set-GitWorktreeDefaults -DefaultRoot /
			} | Should -Throw "Could not convert file 'configuration.json' (*configuration.json)! Is it valid JSON?"
		}

		It "should fail if config file has wrong version" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsWrongVersion"
			{
				Set-GitWorktreeDefaults -DefaultRoot /
			} | Should -Throw "Schema version '0' is not supported for file 'configuration.json' (*configuration.json)."
		}

		It "should fail if config file has no version" {

			. $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup "NoProjectsNoVersion"
			{
				Set-GitWorktreeDefaults -DefaultRoot /
			} | Should -Throw "Schema version is not set for file 'configuration.json' (*configuration.json)."
		}

	}

	Context "With <_> configuration" -ForEach 'Custom', 'Default' {

		BeforeAll {
			$testConfig = . $PSScriptRoot/Helpers/SetGitWorktreeConfig.ps1 -Scope $_ -Setup NoProjects
			$expectedFile = $testConfig.globalConfigFile
		}

		It "should update the config if it exists" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-1"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock ConvertTo-Json { $newMockedContent } -Verifiable -ParameterFilter {
				$InputObject.DefaultRootPath -eq $expectedDefaultRoot `
				-and $InputObject.DefaultSourceBranch -eq $expectedBranch `
				-and $InputObject.SchemaVersion -eq 1
			}

			Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot -DefaultBranch $expectedBranch

			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" -and $inputObject -eq $newMockedContent }
		}

		It "should only update DefaultRoot if that is set" {

			$expectedDefaultRoot = "${TestDrive}"
			Mock Test-Path { $true } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock ConvertTo-Json { $newMockedContent } -Verifiable -ParameterFilter {
				$InputObject.DefaultRootPath -eq $expectedDefaultRoot `
				-and $InputObject.DefaultSourceBranch -eq $testConfig.GlobalConfig.DefaultSourceBranch `
				-and $InputObject.SchemaVersion -eq 1
			}

			Set-GitWorktreeDefaults -DefaultRoot $expectedDefaultRoot

			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" -and $InputObject -eq $newMockedContent }
		}

		It "should only update DefaultBranch if that is set" {

			$expectedBranch = "testing-1"

			Mock ConvertTo-Json { $newMockedContent } -Verifiable -ParameterFilter {
				$InputObject.DefaultRootPath -eq $testConfig.GlobalConfig.DefaultRootPath `
				-and $InputObject.DefaultSourceBranch -eq $expectedBranch `
				-and $InputObject.SchemaVersion -eq 1
			}

			Set-GitWorktreeDefaults -DefaultBranch $expectedBranch

			Should -InvokeVerifiable
			Should -Invoke Out-File -Times 1 -ParameterFilter { $FilePath -eq $expectedFile -and $Encoding -eq "utf8BOM" -and $InputObject -eq $newMockedContent }
		}

		It "should fail if DefaultRoot does not exist" {

			$expectedDefaultRoot = "${TestDrive}"
			$expectedBranch = "testing-2"
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedFile } -Verifiable
			Mock Test-Path { $false } -ParameterFilter { $Path -eq $expectedDefaultRoot } -Verifiable
			Mock Write-Warning {} -ParameterFilter { $Message -like "Global configuration file 'configuration.json' not found! Using default configuration." } -Verifiable
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
	}
}

AfterAll {
	. $PSScriptRoot/Helpers/RestoreGitWorktreeConfigPath.ps1
	Pop-Location
}
