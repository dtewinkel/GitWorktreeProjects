﻿function Remove-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter @args })]
		[String] $Project,

		[Parameter(Mandatory)]
		[ArgumentCompleter({ _gwp__worktreeArgumentCompleter @args })]
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
		$gitResult = InvokeGit worktree remove @forceParameter $worktreeConfig.RelativePath
		if (-not $Force.IsPresent)
		{
			AssertGitSuccess $gitResult | Out-Null
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

New-Alias -Name rgw Remove-GitWorktree
