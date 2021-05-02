function WorktreeFilterArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]

	$projectFilter = $fakeBoundParameters.ProjectFilter
	if ($projectFilter -eq '.')
	{
		$projectFilter = GetCurrentProject
	}

	if (-not $projectFilter)
	{
		return $null
	}

	$projects = GetProjects $ProjectFilter
	if ($projects.Length -lt 1)
	{
		return $null
	}

	$result = foreach ($project in $projects)
	{
		$worktrees = GetProjectConfig -Project $project -WorktreeFilter "${wordToComplete}*" | Select-Object -ExpandProperty Worktrees
		foreach ($worktree in $worktrees)
		{
			$name = $worktree.Name
			$description = "Worktree ${name} for project ${project}."
			[System.Management.Automation.CompletionResult]::new($name, $name, "ParameterValue", $description)
		}
	}
	if(-not $result -or $result.Length -eq 0)
	{
		return $null
	}
	return $result
}
