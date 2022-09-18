function global:_gwp__ProjectArgumentCompleter
{
	param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

	$projects = GetProjects "${wordToComplete}*"
	if (-not $projects -or $projects.Length -eq 0)
	{
		return $null
	}
	foreach ( $project in $projects )
	{
		$projectConfig = GetProjectConfig -Project $project
		$name = $projectConfig.Name
		$description = "Project ${name} in $($projectConfig.RootPath)"
		[System.Management.Automation.CompletionResult]::new($name, $name, "ParameterValue", $description)
	}
}
