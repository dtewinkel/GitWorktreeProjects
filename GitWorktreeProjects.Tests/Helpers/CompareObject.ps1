[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	$Actual,

	[Parameter(Mandatory)]
	$Expected,

	[Parameter(Mandatory)]
	[ValidateSet("Project", "Project[]", "ProjectFile", "Tool", "Tool[]", "Worktree", "Worktree[]", "GlobalConfig", "GlobalConfigFile", "string", "string[]", "int", "int[]")]
	[string] $ExpectedType,

	[Parameter()]
	[switch] $AsBoolean
)

function CompareArray($Actual,	$Expected, $ItemType)
{
	if ($Actual.Length -ne $Expected.Length)
	{
		return $Actual, $Expected.Length, "HaveCount"
	}

	$expectedIndex = 0
	foreach($actualItem in $Actual)
	{
		$actualValue, $expectedValue, $operator, $message = CompareItem $actualItem $expected[$expectedIndex] $ItemType
		if($actualValue -ne $true -or $expectedValue -ne $true)
		{
			return $actualValue, $expectedValue, $operator, $message
		}
		$expectedIndex++
	}
	return $true, $true, "Be"
}

function CompareComplexItem($actual,	$Expected, $itemType)
{
	$properties = [pscustomobject]@{
		Worktree         = 'Name:string', 'InitialCommitish:string', 'RelativePath:string', 'NewBranch:string', 'Tools:Tool[]'
		Tool             = 'Name:string', 'Parameters:string[]'
		Project          = 'Name:string', 'RootPath:string', 'GitPath:string', 'GitRepository:string', 'SourceBranch:string', 'WorkTrees:WorkTree[]', 'Tools:Tool[]'
		ProjectFile      = 'Name:string', 'SchemaVersion:Int32', 'RootPath:string', 'GitPath:string', 'GitRepository:string', 'SourceBranch:string', 'WorkTrees:WorkTree[]', 'Tools:Tool[]'
		GlobalConfig     = 'DefaultRootPath:string', 'DefaultSourceBranch:string', 'DefaultTools:string[]'
		GlobalConfigFile = 'SchemaVersion:Int32', 'DefaultRootPath:string', 'DefaultSourceBranch:string', 'DefaultTools:string[]'
	}.$itemType

	foreach($property in $properties)
	{
		$propertyName, $propertyType = $property -split ':'
		$actualValue, $expectedValue, $operator, $message = CompareItem $Actual.$propertyName $Expected.$propertyName $propertyType
		if($actualValue -ne $true -or $expectedValue -ne $true)
		{
			return $actualValue, $expectedValue, $operator
		}
	}
	return $true, $true, "Be"
}

function CompareItem($Actual,	$Expected, $ExpectedType)
{
	if($null -eq $Actual -and $null -eq $Expected)
	{
		return $true, $true, "Be"
	}
	if($null -eq $Actual)
	{
		return $Actual, $Expected, "Be"
	}
	switch ($ExpectedType)
	{
		{ $PSItem -in ("Project", "ProjectFile", "Tool", "Worktree", "GlobalConfig", "GlobalConfigFile") }
		{
			if ($Actual -isnot $ExpectedType)
			{
				return $Actual, $ExpectedType, "BeOfType"
			}
			return CompareComplexItem $Actual $Expected $ExpectedType
		}

		{ $PSItem -match '\[]$' }
		{
			$actualType = $Actual.GetType()
			$expectedTypes = $ExpectedType, "System.Object[]"
			if ($actualType -notin $expectedTypes)
			{
				return $actualType, $ExpectedTypes, "BeIn", "type should be an array and match"
			}
			$itemType = $PSItem.Trim('[', ']')
			return CompareArray $Actual $Expected $itemType
		}

		default
		{
			if ($actual -isnot $ExpectedType)
			{
				return $actual, $ExpectedType, "BeOfType"
			}
			if ($Actual -cne $Expected)
			{
				return $Actual, $Expected, "BeExactly"
			}
		}
	}
	return $true, $true, "Be"
}


$actualValue, $expectedValue, $operator, $message = CompareItem $Actual $Expected $ExpectedType
if($AsBoolean.IsPresent)
{
	$result = $actualValue -eq $true -and $expectedValue -eq $true
	if(-not $result)
	{
		Write-Warning "[${actualValue}] ${operator} [${expectedValue}] ${message}"
	}
	return $result
}

$actualValue, $expectedValue, $operator, $message
