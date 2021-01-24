function ProjectArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	$path = Join-Path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath *.project
	(Get-ChildItem $path -File).BaseName | Where-Object { $_ -like "*${wordToComplete}*" }
}
