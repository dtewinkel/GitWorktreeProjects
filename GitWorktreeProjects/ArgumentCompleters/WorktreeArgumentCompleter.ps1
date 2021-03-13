function WorktreeArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	$Project = $fakeBoundParameters.Project
	if($Project -eq '.')
	{
		$Project = GetCurrentProject
	}
	if ($Project)
	{
		GetProjectConfig -Project $Project -WorktreeFilter "${wordToComplete}*" | Select-Object -ExpandProperty Worktrees |  ForEach-Object Name
	}
	else
	{
		""
	}
}
