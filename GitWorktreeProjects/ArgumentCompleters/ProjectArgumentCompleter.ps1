function ProjectArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	GetProjects "${wordToComplete}*"
}
