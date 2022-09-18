$worktreeFilterArgumentCompleter = {

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]

	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

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

	$result = foreach ($projectName in $projects)
	{
		$project = GetProjectConfig -Project $projectName -WorktreeFilter "${wordToComplete}*"
		foreach ($worktree in $project.Worktrees)
		{
			$name = $worktree.Name
			$description = "Worktree ${name} for project $($project.Name)"
			[System.Management.Automation.CompletionResult]::new($name, $name, "ParameterValue", $description)
		}
	}
	if(-not $result -or $result.Length -eq 0)
	{
		return $null
	}
	return $result
}

function WorktreeFilterArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	& $worktreeFilterArgumentCompleter $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameters
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName WorktreeFilter -ScriptBlock $worktreeFilterArgumentCompleter
