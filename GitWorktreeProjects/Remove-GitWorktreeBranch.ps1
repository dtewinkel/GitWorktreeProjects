function Remove-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Branch,

		[Parameter()]
		[Switch] $Force
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
			if ($config.Branches.Length -eq 1)
			{
				$config.Branches = $null
			}
			else
			{
				$config.Branches = $config.Branches | Where-Object Name -NE $Branch
			}
			SetProjectConfig -Project $Project -Config $config
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
