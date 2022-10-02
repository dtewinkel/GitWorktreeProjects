[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "WorktreeArgumentCompleter" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command _gwp__worktreeArgumentCompleter
		$command | Should -HaveParameter WordToComplete
		$command | Should -HaveParameter FakeBoundParameters
	}

	It "should expand to nothing when project not found" {

		Mock GetProjects { @() } -ParameterFilter { $Filter -eq 'NonExistingProject' } -Verifiable

		$result = _gwp__worktreeArgumentCompleter -FakeBoundParameters @{ Project = "NonExistingProject" } -WordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when too many projects found" {

		Mock GetProjects { @("1", "2") } -ParameterFilter { $Filter -eq '*' } -Verifiable

		$result = _gwp__worktreeArgumentCompleter -FakeBoundParameters @{ Project = "*" } -WordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project has no working trees" {

		$emptyProject = @{
			Worktrees = @()
		}
		Mock GetProjects { @("P1") } -ParameterFilter { $Filter -eq 'P1' } -Verifiable
		Mock GetProjectConfig { $emptyProject } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq '*' } -Verifiable

		$result = _gwp__worktreeArgumentCompleter -FakeBoundParameters @{ Project = "P1" } -WordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to the working trees of the current project" {

		$projectWithWorktrees = @{
			Worktrees = @(
				@{
					Name = "W1"
					RelativePath = '/w1/path'
				},
				@{
					Name = "Worktree"
					RelativePath = '/w2'
				}
			)
		}
		Mock GetCurrentProject { @("P1") } -Verifiable
		Mock GetProjects { @("P1") } -ParameterFilter { $Filter -eq 'P1' } -Verifiable
		Mock GetProjectConfig { $projectWithWorktrees } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq 'W*' } -Verifiable

		$result = _gwp__worktreeArgumentCompleter -FakeBoundParameters @{ Project = '.' } -WordToComplete "W"

		Should -InvokeVerifiable
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "W1"
		$result[0].ListItemText | Should -Be "W1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Working tree W1 in /w1/path"
		$result[1].CompletionText | Should -Be "Worktree"
		$result[1].ListItemText | Should -Be "Worktree"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Working tree Worktree in /w2"
	}
}
