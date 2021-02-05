function ProjectArgumentCompleter($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
{
	$path = GetConfigFilePath -ChildPath *.project
	(Get-ChildItem $path -File).BaseName | Where-Object { $_ -like "*${wordToComplete}*" }
}
