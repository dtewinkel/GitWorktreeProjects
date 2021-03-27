function Open-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Worktree
	)

	process
	{
		$projectConfig = GetProjectConfig -Project $Project -WorktreeFilter $Worktree -WorktreeExactMatch -FailOnMissing
		$worktreeConfig = $projectConfig.Worktrees[0]
		$fullPath = Join-Path $projectConfig.RootPath $worktreeConfig.RelativePath
		if (-not (Test-Path $fullPath))
		{
			$projectName = $projectConfig.Name
			throw "Path '${fullPath}' for worktree '${Worktree}' in project '${projectName}' not found!"
		}
		Set-Location $fullPath
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Worktree -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ogw Open-GitWorktree
