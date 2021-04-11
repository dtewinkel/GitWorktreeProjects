[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	$Actual,

	[Parameter(Mandatory)]
	$Expected,

	[Parameter(Mandatory)]
	[ValidateSet("Project", "Project[]", "ProjectFile", "Tool", "Tool[]", "Worktree", "Worktree[]", "GlobalConfig", "GlobalConfigFile", "string", "string[]", "int", "int[]")]
	[string] $ExpectedType
)

$actualValue, $expectedValue, $operator, $message = & $PSScriptRoot/CompareObject.ps1 $Actual $Expected $ExpectedType
$expectedParam = "ExpectedValue"
if($operator -in ('BeOfType'))
{
	$expectedParam = "ExpectedType"
}
$params = @{ $operator = $true; $expectedParam = $expectedValue; Because = $message }
$actualValue | Should @params

