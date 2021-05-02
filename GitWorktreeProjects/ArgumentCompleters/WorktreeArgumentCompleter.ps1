function WorktreeArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]

	$project = $fakeBoundParameters.Project
	if ($project -eq '.')
	{
		$project = GetCurrentProject
	}
	$projects = @(GetProjects $project)
	if ($projects.Length -ne 1 -or $projects[0] -ne $project)
	{
		return $null
	}
	$worktrees = GetProjectConfig -Project $projects[0] -WorktreeFilter "${wordToComplete}*" | Select-Object -ExpandProperty Worktrees
	if (-not $worktrees -or $worktrees.Length -eq 0)
	{
		return $null
	}
	foreach ($worktree in $worktrees)
	{
		$name = $worktree.Name
		$description = "Worktree ${name} in $($worktree.RelativePath)"
		[System.Management.Automation.CompletionResult]::new($name, $name, "ParameterValue", $description)
	}
}
