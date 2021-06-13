[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "WorktreeFilterArgumentCompleter" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "should have the right parameters" {

		$command = Get-Command WorktreeFilterArgumentCompleter
		$command | Should -HaveParameter wordToComplete
		$command | Should -HaveParameter fakeBoundParameters
	}

	It "should expand to nothing when project not found" {

		Mock GetProjects { @() } -ParameterFilter { $Filter -eq 'NonExistingProject' } -Verifiable

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "NonExistingProject" } -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project filter not supplied" {

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{} -wordToComplete ""

		$result | Should -BeNullOrEmpty
	}

	It "should expand to nothing when project has no worktrees" {

		$emptyProject = @{
			Worktrees = @()
		}
		Mock GetProjects { @("P1") } -ParameterFilter { $Filter -eq 'P1' } -Verifiable
		Mock GetProjectConfig { $emptyProject } -ParameterFilter { $Project -eq 'P1' -and $WorktreeFilter -eq '*' } -Verifiable

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "P1" } -wordToComplete ""

		Should -InvokeVerifiable
		$result | Should -BeNullOrEmpty
	}

	It "should expand to worktrees for all found projects" {

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

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = "*" } -wordToComplete "W"

		Should -InvokeVerifiable
		$result | Should -HaveCount 3
		$result[0].CompletionText | Should -Be "W1"
		$result[0].ListItemText | Should -Be "W1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree W1 for project P1"
		$result[1].CompletionText | Should -Be "Worktree"
		$result[1].ListItemText | Should -Be "Worktree"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree Worktree for project P1"
		$result[2].CompletionText | Should -Be "X1"
		$result[2].ListItemText | Should -Be "X1"
		$result[2].ResultType | Should -Be "ParameterValue"
		$result[2].ToolTip | Should -BeLike "Worktree X1 for project P2"
	}

	It "should expand to the worktrees of the current project" {

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

		$result = WorktreeFilterArgumentCompleter -fakeBoundParameters @{ ProjectFilter = '.' } -wordToComplete "W"

		Should -InvokeVerifiable
		$result | Should -HaveCount 2
		$result | Should -HaveCount 2
		$result[0].CompletionText | Should -Be "W1"
		$result[0].ListItemText | Should -Be "W1"
		$result[0].ResultType | Should -Be "ParameterValue"
		$result[0].ToolTip | Should -BeLike "Worktree W1 for project P1"
		$result[1].CompletionText | Should -Be "Worktree"
		$result[1].ListItemText | Should -Be "Worktree"
		$result[1].ResultType | Should -Be "ParameterValue"
		$result[1].ToolTip | Should -BeLike "Worktree Worktree for project P1"
	}
}
