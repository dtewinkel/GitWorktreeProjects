function BranchArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	$Project = $fakeBoundParameters.Project
	if ($Project)
	{
		$configFile = Join-Path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath "${Project}.project"
		if (Test-Path $configFile)
		{
			((Get-Content $configFile | ConvertFrom-Json).Branches | Where-Object Name -Like "*${wordToComplete}*").Name
		}
		else
		{
			""
		}
	}
	else
	{
		""
	}
}
