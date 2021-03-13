function Remove-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Worktree,

		[Parameter()]
		[Switch] $Force
	)

	process
	{
		$config = GetProjectConfig -Project $Project -FailOnMissing
		$worktree = $config.worktrees | Where-Object Name -EQ $Worktree
		if (-not $worktree)
		{
			throw "Worktree '${Worktree}' not found in project configuration!"
		}
		$worktreePath = Join-Path $config.RootPath $worktree.RelativePath
		if (-not (Test-Path $worktreePath))
		{
			throw "Branch Path '${worktreePath} not found"
		}
		$gitPath = $config.GitPath
		if (-not (Test-Path $gitPath))
		{
			throw "Path '${gitPath} not found"
		}
		Push-Location
		try
		{
			Set-Location $gitPath
			$forceParameter = @()
			if($Force.IsPresent)
			{
				$forceParameter = @('--force')
			}
			git worktree remove @forceParameter $branchInfo.RelativePath
			if($LastExitCode -ne 0)
			{
				throw "Git failed with exit code ${LastExitCode}."
			}
			if (Test-Path $branchPath)
			{
				throw "failed to remove folder '${branchPath}'."
			}
			if ($config.Worktrees.Length -eq 1)
			{
				$config.Worktrees = $null
			}
			else
			{
				$config.Worktrees = $config.Worktrees | Where-Object Name -NE $Worktree
			}
			SetProjectConfig -Project $Project -Config $config
		}
		finally
		{
			Pop-Location
		}
	}
}

Register-ArgumentCompleter -CommandName Remove-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Remove-GitWorktree -ParameterName Branch -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name rgw Remove-GitWorktree
