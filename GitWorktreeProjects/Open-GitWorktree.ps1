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
		$config = GetProjectConfig -Project $Project
		$worktree = $config.Worktrees | Where-Object Name -EQ $Worktree
		if (-not $worktree)
		{
			throw "Worktree '${Worktree}' for project '${Project}' not found!"
		}
		$fullPath = Join-Path $config.RootPath $worktree.RelativePath
		if (-not (Test-Path $fullPath))
		{
			throw "Path '${fullPath} for worktree '${Worktree}' not found"
		}
		Set-Location $fullPath
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Worktree -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ogw Open-GitWorktree
