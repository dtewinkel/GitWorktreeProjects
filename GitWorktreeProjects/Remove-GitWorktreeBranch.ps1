function Remove-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Branch
	)

	process
	{
		$config = GetProjectConfig -Project $Project
		$branchInfo = $config.Branches | Where-Object Name -EQ $Branch
		if (-not $branchInfo)
		{
			throw "Branch '${Branch}' not found in project configuration!"
		}
		$branchPath = Join-Path $config.RootPath $branchInfo.RelativePath
		if (-not (Test-Path $branchPath))
		{
			throw "Branch Path '${branchPath} not found"
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
			git worktree remove $branchInfo.RelativePath
			if ($config.Branches.Length -eq 1)
			{
				$config.Branches = $null
			}
			else
			{
				$config.Branches = $config.Branches | Where-Object Name -NE $Branch
			}
		}
		finally
		{
			Pop-Location
		}
	}
}

Register-ArgumentCompleter -CommandName Remove-GitWorktreeBranch -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Remove-GitWorktreeBranch -ParameterName Branch -ScriptBlock ${function:BranchArgumentCompleter}

New-Alias -Name rgwb Remove-GitWorktreeBranch
