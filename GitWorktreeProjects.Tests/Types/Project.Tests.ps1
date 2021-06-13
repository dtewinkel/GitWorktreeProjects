[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "Project" {

	BeforeAll {
		$name = "myBestProject"
		$rootPath = '/default/root/path'
		$gitPath = '/git/path'
		$gitRepository = 'https://git/repo'
		$sourceBranch = '/source/branch'
		$worktrees = @(
			@{
				Name             = 'worktree1'
				InitialCommitish = 'main'
				RelativePath     = 'worktree1'
				NewBranch        = 'worktree1'
				Tools            = @(
					@{
						Name = 'firstTool'
					}
				)
			}
			@{
				Name             = 'worktree2'
				InitialCommitish = 'worktree2'
				RelativePath     = 'myWorktree'
				NewBranch        = $null
				Tools            = @(
					@{
						Name = 'firstTool'
					}
					@{
						Name       = 'anotherTool'
						Parameters = @("one", "two")
					}
				)
			}
		)
		$tools = @(
			@{
				Name       = "tool1"
				Parameters = @("A", "B")
			},
			@{
				Name = 'another tool'
			}
		)

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "Can be converted from file contents" {

		$fileContents = @{
			SchemaVersion = 1
			Name          = $name
			RootPath      = $rootPath
			GitPath       = $gitPath
			GitRepository = $gitRepository
			SourceBranch  = $sourceBranch
			Worktrees     = $worktrees
			Tools         = $tools
		}

		$project = [Project]::FromFile($fileContents)

		$project.Name | Should -Be $name
		$project.RootPath | Should -Be $rootPath
		$project.GitPath | Should -Be $gitPath
		$project.GitRepository | Should -Be $gitRepository
		$project.SourceBranch | Should -Be $sourceBranch

		$project.Worktrees | Should -HaveCount 2
		$project.Worktrees[0].Name | Should -Be $worktrees[0].Name
		$project.Worktrees[0].InitialCommitish | Should -Be $worktrees[0].InitialCommitish
		$project.Worktrees[0].RelativePath | Should -Be $worktrees[0].RelativePath
		$project.Worktrees[0].NewBranch | Should -Be $worktrees[0].NewBranch
		$project.Worktrees[0].Tools | Should -HaveCount 1
		$project.Worktrees[0].Tools[0].Name | Should -Be $worktrees[0].Tools[0].Name
		$project.Worktrees[0].Tools[0].Parameters | Should -BeNullOrEmpty
		$project.Worktrees[1].Name | Should -Be $worktrees[1].Name
		$project.Worktrees[1].InitialCommitish | Should -Be $worktrees[1].InitialCommitish
		$project.Worktrees[1].RelativePath | Should -Be $worktrees[1].RelativePath
		$project.Worktrees[1].NewBranch | Should -BeNullOrEmpty
		$project.Worktrees[1].Tools | Should -HaveCount 2
		$project.Worktrees[1].Tools[0].Name | Should -Be $worktrees[1].Tools[0].Name
		$project.Worktrees[1].Tools[0].Parameters | Should -BeNullOrEmpty
		$project.Worktrees[1].Tools[1].Name | Should -Be $worktrees[1].Tools[1].Name
		$project.Worktrees[1].Tools[1].Parameters | Should -HaveCount 2
		$project.Worktrees[1].Tools[1].Parameters[0] | Should -Be $Worktrees[1].Tools[1].Parameters[0]
		$project.Worktrees[1].Tools[1].Parameters[1] | Should -Be $Worktrees[1].Tools[1].Parameters[1]

		$project.Tools | Should -HaveCount 2
		$project.Tools[0].Name | Should -Be $tools[0].Name
		$project.Tools[0].Parameters | Should -HaveCount 2
		$project.Tools[0].Parameters[0] | Should -Be $tools[0].Parameters[0]
		$project.Tools[0].Parameters[1] | Should -Be $tools[0].Parameters[1]
		$project.Tools[1].Name | Should -Be $tools[1].Name
		$project.Tools[1].Parameters | Should -HaveCount 0
	}

	It "Can be converted to file contents" {

		$project = [Project]::new()
		$project.Name = $name
		$project.RootPath = $rootPath
		$project.GitPath = $gitPath
		$project.GitRepository = $gitRepository
		$project.SourceBranch = $sourceBranch
		$project.Worktrees = $worktrees
		$project.Tools = $tools

		$fileContents = $project.ToFile()

		$fileContents.SchemaVersion | Should -Be 1
		$fileContents.Name | Should -Be $name
		$fileContents.RootPath | Should -Be $rootPath
		$fileContents.GitPath | Should -Be $gitPath
		$fileContents.GitRepository | Should -Be $gitRepository
		$fileContents.SourceBranch | Should -Be $sourceBranch

		$fileContents.Worktrees | Should -HaveCount 2
		$fileContents.Worktrees[0].Name | Should -Be $worktrees[0].Name
		$fileContents.Worktrees[0].InitialCommitish | Should -Be $worktrees[0].InitialCommitish
		$fileContents.Worktrees[0].RelativePath | Should -Be $worktrees[0].RelativePath
		$fileContents.Worktrees[0].NewBranch | Should -Be $worktrees[0].NewBranch
		$fileContents.Worktrees[0].Tools | Should -HaveCount 1
		$fileContents.Worktrees[0].Tools[0].Name | Should -Be $worktrees[0].Tools[0].Name
		$fileContents.Worktrees[0].Tools[0].Parameters | Should -BeNullOrEmpty
		$fileContents.Worktrees[1].Name | Should -Be $worktrees[1].Name
		$fileContents.Worktrees[1].InitialCommitish | Should -Be $worktrees[1].InitialCommitish
		$fileContents.Worktrees[1].RelativePath | Should -Be $worktrees[1].RelativePath
		$fileContents.Worktrees[1].NewBranch | Should -BeNullOrEmpty
		$fileContents.Worktrees[1].Tools | Should -HaveCount 2
		$fileContents.Worktrees[1].Tools[0].Name | Should -Be $worktrees[1].Tools[0].Name
		$fileContents.Worktrees[1].Tools[0].Parameters | Should -BeNullOrEmpty
		$fileContents.Worktrees[1].Tools[1].Name | Should -Be $worktrees[1].Tools[1].Name
		$fileContents.Worktrees[1].Tools[1].Parameters | Should -HaveCount 2
		$fileContents.Worktrees[1].Tools[1].Parameters[0] | Should -Be $Worktrees[1].Tools[1].Parameters[0]
		$fileContents.Worktrees[1].Tools[1].Parameters[1] | Should -Be $Worktrees[1].Tools[1].Parameters[1]

		$fileContents.Tools | Should -HaveCount 2
		$fileContents.Tools[0].Name | Should -Be $tools[0].Name
		$fileContents.Tools[0].Parameters | Should -HaveCount 2
		$fileContents.Tools[0].Parameters[0] | Should -Be $tools[0].Parameters[0]
		$fileContents.Tools[0].Parameters[1] | Should -Be $tools[0].Parameters[1]
		$fileContents.Tools[1].Name | Should -Be $tools[1].Name
		$fileContents.Tools[1].Parameters | Should -HaveCount 0	}
}
