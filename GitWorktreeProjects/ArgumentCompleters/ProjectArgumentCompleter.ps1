$projectArgumentCompleter = {

	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]

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

function ProjectArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	& $projectArgumentCompleter $commandName $parameterName $wordToComplete $commandAst $fakeBoundParameters
}


Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock $projectArgumentCompleter
Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName ProjectFilter -ScriptBlock $projectArgumentCompleter
Register-ArgumentCompleter -CommandName New-GitWorktree -ParameterName Project -ScriptBlock $projectArgumentCompleter
Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Project -ScriptBlock $projectArgumentCompleter
Register-ArgumentCompleter -CommandName Remove-GitWorktree -ParameterName Project -ScriptBlock $projectArgumentCompleter
