[CmdletBinding()]
param (
)

$testProject1 = [PSCustomObject]@{
	SchemaVersion = 1
	Name          = 'Testing123'
	RootPath      = 'RootPath/Testing123'
	GitPath       = 'GitPath/Testing123'
	GitRepository = "https://Testing123.repository"
	SourceBranch  = "main"
	Worktrees     = @(
		[PSCustomObject]@{
			Name = "main"
		}
		[PSCustomObject]@{
			Name = "Test123"
		}
		[PSCustomObject]@{
			Name = "Demo123"
		}
	)
}

$testProject2 = [PSCustomObject]@{
	SchemaVersion = 1
	Name          = 'TestDemoProject'
	RootPath      = 'RootPath/DemoProject'
	GitPath       = 'GitPath/DemoProject'
	GitRepository = "https://DemoProject.repository"
	SourceBranch  = "main"
	Worktrees     = @(
		[PSCustomObject]@{
			Name = "DemoProject"
		}
		[PSCustomObject]@{
			Name = "SomeBranch"
		}
	)
}

return $testProject1, $testProject2
