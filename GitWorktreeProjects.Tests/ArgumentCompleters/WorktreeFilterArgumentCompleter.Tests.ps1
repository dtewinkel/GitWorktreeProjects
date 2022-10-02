[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder = (Resolve-Path (Join-Path $PSScriptRoot '..' '..', 'GitWorktreeProjects')).Path
)

Describe "WorktreeFilterArgumentCompleter" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command _gwp__worktreeFilterArgumentCompleter
		$command | Should -HaveParameter wordToComplete
		$command | Should -HaveParameter fakeBoundParameters
	}

	It "should expand to nothing when project not found" {

		Mock GetProjects { @() } -ParameterFilter { $Filter -eq 'NonExistingProject' } -Verifiable

		$result = _gwp__worktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "NonExistingProject" } -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project filter not supplied" {

		$result = _gwp__worktreeFilterArgumentCompleter -fakeBoundParameters @{} -wordToComplete ""

		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project has no working trees" {

		$emptyProject = @{
			Worktrees = @()
		}
		Mock GetProjects { @("P1") } -ParameterFilter { $Filter -eq 'P1' } -Verifiable
		Mock GetProjectConfig { $emptyProject } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq '*' } -Verifiable

		$result = _gwp__worktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "P1" } -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to working trees for all found projects" {

		$projectsWithWorktrees = @(
			@{
				Name = "P1"
				Worktrees = @(
					@{
						Name         = "W1"
						RelativePath = '/w1/path'
					},
					@{
						Name         = "Worktree"
						RelativePath = '/w2'
					}
				)
			}
			@{
				Name = "P2"
				Worktrees = @(
					@{
						Name         = "X1"
						RelativePath = '/x1/path'
					}
				)
			}
			@{
				Name = "P3"
				Worktrees = @(
				)
			}
		)
		Mock GetProjects { @("P1", "P2", "P3") } -ParameterFilter { $Filter -eq '*' } -Verifiable
		Mock GetProjectConfig { $projectsWithWorktrees[0] } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq 'W*' } -Verifiable
		Mock GetProjectConfig { $projectsWithWorktrees[1] } -ParameterFilter { $Project -eq 'P2' -and $WorktreeFilter -eq 'W*' } -Verifiable
		Mock GetProjectConfig { $projectsWithWorktrees[2] } -ParameterFilter { $Project -eq 'P3' -and $WorktreeFilter -eq 'W*' } -Verifiable

		$result = _gwp__worktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "*" } -wordToComplete "W"

		Should -InvokeVerifiable
		$result | Should -HaveCount 3
		$result[0].CompletionText | Should -Be "W1"
		$result[0].ListItemText | Should -Be "W1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Working tree W1 for project P1"
		$result[1].CompletionText | Should -Be "Worktree"
		$result[1].ListItemText | Should -Be "Worktree"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Working tree Worktree for project P1"
		$result[2].CompletionText | Should -Be "X1"
		$result[2].ListItemText | Should -Be "X1"
		$result[2].ResultType | Should -Be "ParameterValue"
		$result[2].ToolTip | Should -BeLike "Working tree X1 for project P2"
	}

	It "should expand to the working trees of the current project" {

		$projectWithWorktrees = @{
			Name      = "P1"
			Worktrees = @(
				@{
					Name         = "W1"
					RelativePath = '/w1/path'
				},
				@{
					Name         = "Worktree"
					RelativePath = '/w2'
				}
			)
		}
		Mock GetCurrentProject { @("P1") } -Verifiable
		Mock GetProjects { @("P1") } -ParameterFilter { $Filter -eq 'P1' } -Verifiable
		Mock GetProjectConfig { $projectWithWorktrees } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq 'W*' } -Verifiable

		$result = _gwp__worktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = '.' } -wordToComplete "W"

		Should -InvokeVerifiable
		$result | Should -HaveCount 2
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "W1"
		$result[0].ListItemText | Should -Be "W1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Working tree W1 for project P1"
		$result[1].CompletionText | Should -Be "Worktree"
		$result[1].ListItemText | Should -Be "Worktree"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Working tree Worktree for project P1"
	}
}
