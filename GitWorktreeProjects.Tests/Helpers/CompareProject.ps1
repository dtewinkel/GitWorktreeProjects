[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	$Actual,

	[Parameter(Mandatory)]
	$Expected,

	[Parameter()]
	[ValidateSet("Project", "ProjectFile", "Project[]")]
	$ExpectedType = "Project"
)

switch ($ExpectedType)
{
	{ $PSItem -in ("Project", "ProjectFile") }
	{
		$Actual.GetType() | Should -Be $ExpectedType
		$Actual = @($Actual)
		$Expected = @($Expected)
	}

	"Project[]"
	{
		$ExpectedType = "Project"
	}
}

$projectIndex = 0
foreach ($ActualItem in $Actual)
{
	$ActualItem.GetType() | Should -Be $ExpectedType

	$projectName = $ActualItem.Name
	$expectedItem = $Expected | Where-Object Name -CEQ $projectName
	$expectedItem | Should -Not -BeNull -Because "Project '${projectName}' must exist in test data"

	$worktreePorperties = 'Name', 'InitialCommitish', 'RelativePath', 'NewBranch'
	$properties = 'Name', 'RootPath', 'GitPath', 'GitRepository', 'SourceBranch'

	if ($ExpectedType -eq "ProjectFile" )
	{
		$properties += 'SchemaVersion'
	}

	foreach ($property in $properties)
	{
		$ActualItem.${property} | Should -BeExactly $expectedItem.${property} -Because "property $property should match"
	}

	$ActualItem.Worktrees.Count | Should -Be $expectedItem.Worktrees.Count -Because "Property Worktrees should have the expected number of items"
	$WorktreeIndex = 0;
	foreach ($actualWorktree in $ActualItem.Worktrees)
	{
		$worktreeName = $actualWorktree.Name
		$expectedWorktree = $expectedItem.Worktrees | Where-Object Name -CEQ $worktreeName
		$expectedWorktree | Should -Not -BeNull -Because "Worktree '${worktreeName}' must exist in test data for project '${projectName}'"
		foreach ($property in $worktreePorperties)
		{
			$actualWorktree.${property} | Should -BeExactly $expectedWorktree.${property} -Because "property Worktrees[$WorktreeIndex].$property should match"
		}
		$WorktreeIndex++
	}
	$projectIndex++
}
