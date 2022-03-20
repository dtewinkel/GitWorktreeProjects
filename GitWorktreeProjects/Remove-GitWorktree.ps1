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

	$config = GetProjectConfig -Project $Project -FailOnMissing
	$worktreeConfig = $config.worktrees | Where-Object Name -CEQ $Worktree
	if (-not $worktreeConfig)
	{
		throw "Worktree '${Worktree}' not found in project '$($config.Name)' configuration!"
	}
	$worktreePath = (Get-Item (Join-Path $config.RootPath $worktreeConfig.RelativePath)).FullName
	if (-not (Test-Path $worktreePath) -and -not $Force.IsPresent)
	{
		throw "Worktree path '${worktreePath} not found"
	}
	$gitPath = $config.GitPath
	if (-not (Test-Path $gitPath))
	{
		throw "Path '${gitPath} not found"
	}
	try
	{
		$currentLocation = Get-Location
		if ($worktreePath -ceq $currentLocation)
		{
			Set-Location $config.RootPath
		}
		Push-Location $gitPath
		$forceParameter = @()
		if ($Force.IsPresent)
		{
			$forceParameter = @('--force')
		}
		git worktree remove @forceParameter $worktreeConfig.RelativePath
		if ($LastExitCode -ne 0 -and -not $Force.IsPresent)
		{
			throw "Git failed with exit code ${LastExitCode}."
		}
		if (Test-Path $worktreePath)
		{
			throw "Failed to remove folder '${worktreePath}'."
		}
		if ($config.Worktrees.Length -eq 1)
		{
			$config.Worktrees = $null
		}
		else
		{
			$config.Worktrees = $config.Worktrees | Where-Object Name -CNE $Worktree
		}
		SetProjectConfig -Project $config.Name -ProjectConfig $config
	}
	finally
	{
		Pop-Location
	}
}

Register-ArgumentCompleter -CommandName Remove-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Remove-GitWorktree -ParameterName Worktree -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name rgw Remove-GitWorktree
