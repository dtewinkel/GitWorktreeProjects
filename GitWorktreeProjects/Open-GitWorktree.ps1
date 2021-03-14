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
		$config = GetProjectConfig -Project $Project -WorktreeFilter $Worktree -WorktreeExactMatch -FailOnMissing
		$worktreeConfig = $config.Worktrees[0]
		$fullPath = Join-Path $config.RootPath $worktreeConfig.RelativePath
		if (-not (Test-Path $fullPath))
		{
			throw "Path '${fullPath}' for worktree '${Worktree}' in project '${Project}' not found!"
		}
		Set-Location $fullPath
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Worktree -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ogw Open-GitWorktree
