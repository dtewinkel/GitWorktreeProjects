[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	$Actual,

	[Parameter(Mandatory)]
	$Expected,

	[Parameter()]
	[ValidateSet("Project", "ProjectFile")]
	$ExpectedType = "Project"
)

$Actual.GetType() | Should -Be $ExpectedType

$worktreePorperties = 'Name', 'InitialCommitish', 'RelativePath', 'NewBranch'
$properties = 'Name','RootPath', 'GitPath', 'GitRepository', 'SourceBranch'

if($ExpectedType -eq "ProjectFile" )
{
		$properties += 'SchemaVersion'
}

foreach ($property in $properties)
{
	$Actual.${property} | Should -BeExactly $Expected.${property} -Because "property $property should match"
}

$Actual.Worktrees.Count | Should -Be $Expected.Worktrees.Count -Because "Property Worktrees should have the expected number of items"
$index = 0;
foreach($actualWorktree in $Actual.Worktrees)
{
	$expectedWorktree = $Expected.Worktrees[$index]
	foreach ($property in $worktreePorperties)
	{
		$actualWorktree.${property} | Should -BeExactly $expectedWorktree.${property} -Because "property Worktrees[$index].$property should match"
	}
	$index++
}
