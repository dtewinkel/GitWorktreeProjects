[CmdletBinding()]
param (
	[Parameter()]
	[string]
	$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' 'GitWorktreeProjects')).Path
)

Describe "Open-GitWorktree" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/TestHelpers/LoadModule.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {
		$command = Get-Command Open-GitWorktree

		$command | Should -HaveParameter Project -HasArgumentCompleter
		$command | Should -HaveParameter Worktree -Mandatory -HasArgumentCompleter
		$command | Should -HaveParameter NoTools
	}

	It "should fail if it cannot get the project or working tree" {
		{
			$projectName = "NonExisting"
			$worktreeName = "None"

			Mock GetProjectConfig { Throw "oops..." } -ParameterFilter { $Project -eq $projectName -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable

			Open-GitWorktree -Project $projectName -Worktree $worktreeName
		} | Should -Throw "Oops..."

		Should -InvokeVerifiable
	}

	It "should fail if the working tree path does not exist" {

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq $projectName -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $false } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects

		{
			Open-GitWorktree -Project $projectName -Worktree $worktreeName
		} | Should -Throw "Path '${fullPath}' for working tree '${worktreeName}' in project '${projectName}' not found!"

		Should -InvokeVerifiable
	}

	It "Should change to the right folder for a specific project" {

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
					Tools        = @()
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq $projectName -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Set-Location {} -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects

		Open-GitWorktree -Project $projectName -Worktree $worktreeName

		Should -InvokeVerifiable
	}

	It "Should change to the right folder for the current project" {

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
					Tools        = @()
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Set-Location {} -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects

		Open-GitWorktree -Project . -Worktree $worktreeName

		Should -InvokeVerifiable
	}

	It "Should fail if a tools for the working tree is not found" {

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$tool1Name = "Tool1"
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
					Tools        = @(
						@{
							Name = $tool1Name
						}
					)
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Set-Location {} -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Get-Item {} -ParameterFilter { $Path -eq "function:Invoke-Tool${tool1Name}" -and $ErrorAction -eq 'SilentlyContinue' } -Verifiable -ModuleName GitWorktreeProjects

		{ Open-GitWorktree -Project . -Worktree $worktreeName } | Should -Throw "Tool '$tool1Name' not found. Is it installed and registerd?"

		Should -InvokeVerifiable
	}

	It "Should execute the tools as defined for the working tree" {

		$script:fn1ProjectConfig = $Null
		$script:fn1Parameters = $null
		$script:fn2ProjectConfig = $Null
		$script:fn2Parameters = $null

		function fn1($ProjectConfig, $Parameters)
		{
			$script:fn1ProjectConfig = $ProjectConfig
			$script:fn1Parameters = $Parameters
		}

		function global:fn2($ProjectConfig, $Parameters)
		{
			$script:fn2ProjectConfig = $ProjectConfig
			$script:fn2Parameters = $Parameters
		}

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$Tool1Name = "Tool1"
		$Tool2Name = "AnotherTool"
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
					Tools        = @(
						@{
							Name = $Tool1Name
						}
						@{
							Name       = $Tool2Name
							Parameters = @( 'p1', 'p2' )
						}
					)
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Set-Location {} -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Get-Item { $Function:fn1 } -ParameterFilter { $Path -eq "function:Invoke-Tool${tool1Name}" -and $ErrorAction -eq 'SilentlyContinue' } -Verifiable -ModuleName GitWorktreeProjects
		Mock Get-Item { $Function:fn2 } -ParameterFilter { $Path -eq "function:Invoke-Tool${tool2Name}" -and $ErrorAction -eq 'SilentlyContinue' } -Verifiable -ModuleName GitWorktreeProjects

		Open-GitWorktree -Project . -Worktree $worktreeName

		$script:fn1ProjectConfig | Should -Be $ProjectConfig
		$script:fn1Parameters | Should -BeNullOrEmpty
		$script:fn2ProjectConfig | Should -Be $ProjectConfig
		$script:fn2Parameters | Should -Be $projectConfig.Worktrees[0].Tools[1].Parameters

		Should -InvokeVerifiable
	}

	It "Should not execute the tools as defined for the working tree if NoTools is given" {

		$projectName = "TestProject"
		$worktreeName = "myWorktree"
		$projectPath = '/test/project'
		$worktreePath = 'myWorktree'
		$Tool1Name = "Tool1"
		$Tool2Name = "AnotherTool"
		$fullPath = "${projectPath}/${woktreePath}"

		$projectConfig = @{
			Name      = $projectName
			RootPath  = $projectPath
			Worktrees = @(
				@{
					RelativePath = $worktreePath
					Tools        = @(
						@{
							Name = $Tool1Name
						}
						@{
							Name       = $Tool2Name
							Parameters = @( 'p1', 'p2' )
						}
					)
				}
			)
		}

		Mock GetProjectConfig { $projectConfig } -ParameterFilter { $Project -eq '.' -and $WorktreeFilter -eq $worktreeName -and $WorktreeExactMatch -and $FailOnMissing } -ModuleName GitWorktreeProjects -Verifiable
		Mock Join-Path { $fullPath } -ParameterFilter { $Path -eq $projectPath -and $ChildPath -eq $worktreePath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Test-Path { $true } -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Set-Location {} -ParameterFilter { $Path -eq $fullPath } -Verifiable -ModuleName GitWorktreeProjects
		Mock Get-Item { } -ParameterFilter { $Path -like "function:Invoke-Tool*" -and $ErrorAction -eq 'SilentlyContinue' } -ModuleName GitWorktreeProjects

		Open-GitWorktree -Project . -Worktree $worktreeName -NoTools

		Should -InvokeVerifiable
		Should -Not -Invoke Get-Item -ParameterFilter { $Path -like "function:Invoke-Tool*" -and $ErrorAction -eq 'SilentlyContinue' } -ModuleName GitWorktreeProjects
	}
}
