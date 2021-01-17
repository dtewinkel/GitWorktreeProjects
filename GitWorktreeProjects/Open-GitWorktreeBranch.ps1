function Open-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $Branch,

		[Parameter()]
		[Switch] $NoTools
	)

	process {
		Set-Location $Path
		Set-Location $Project
		$host.ui.RawUI.WindowTitle = "${Project} - ${Branch}"
		if ($Branch -and (Test-Path $Branch))
		{
			Set-Location $Branch
			if (-not $NoTools.IsPresent)
			{
				code .
				Start-SourceTree
			}
		}
	}
}

$ProjectArgumentCompleter = {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

	Set-Location (Join-Path -Path $env:PROJECT_ROOT -ChildPath $env:PROJECT_COMPANY -AdditionalChildPath $env:PROJECT_GROUP)
	(Get-ChildItem */.bare).Parent.Name | Where-Object { $_ -like "*${wordToComplete}*" }
}

Register-ArgumentCompleter -CommandName Open-GitWorktreeBranch -ParameterName Project -ScriptBlock $ProjectArgumentCompleter

$BranchArgumentCompleter = {
	param ($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

	if ($fakeBoundParameters.Project -or (Test-Path '.bare'))
	{
		if ($fakeBoundParameters.Project)
		{
			Set-Location (Join-Path -Path $env:PROJECT_ROOT -ChildPath $env:PROJECT_COMPANY -AdditionalChildPath $env:PROJECT_GROUP)
			Set-Location $fakeBoundParameters.Project
		}
		((Get-ChildItem -File .git -Recurse -Force -Depth 2).Directory | Resolve-Path -Relative) -replace '\.[/\\]', '' -replace '\\', '/' | Where-Object { $_ -like "*${wordToComplete}*" }
	}
	else
	{
		""
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktreeBranch -ParameterName Branch -ScriptBlock $BranchArgumentCompleter

New-alias -Name ogwb Open-GitWorktreeBranch
