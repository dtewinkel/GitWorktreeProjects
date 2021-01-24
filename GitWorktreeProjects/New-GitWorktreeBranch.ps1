function New-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $Commitish,

		[Parameter()]
		[String] $NewBranch,

		[Parameter()]
		[String] $Name,

		[Parameter()]
		[String] $Path
	)

	begin
	{
		$git = Get-Command git
		if (-not $git)
		{
			throw "git not found!"
		}

		if (-not $Commitish -and -not $Path -and -not $Name)
		{
			throw "At lease one of -Commitish, -Path and -Name must be given."
		}
	}

	process
	{
		$projectConfig = GetProjectConfig -Project $Project

		if (-not $Commitish)
		{
			$Commitish = $projectConfig.MainBranch
		}
		if (-not $Name)
		{
			$Name = $NewBranch
			if (-not $Name)
			{
				$Name = $Commitish
			}
		}
		if (-not $Path)
		{
			$Path = $Name
		}

		$branchInfo = $projectConfig.Branches | Where-Object Name -EQ $Name
		if ($branchInfo)
		{
			throw "Branch with name '${Name}' already exists!"
		}

		Set-Location -Path $projectConfig.GitPath
		$branchPath = Join-Path $projectConfig.RootPath $Path
		if (Test-Path $branchPath)
		{
			throw "Path '${branchPath}' already exists!"
		}

		if ($NewBranch)
		{
			git worktree add -b $NewBranch $branchPath $Commitish
		}
		else
		{
			git worktree add $branchPath $Commitish
		}
		Set-Location $branchPath
		$branchInfo = [BranchInfo]::new()
		$branchInfo.Name = $Name
		$branchInfo.RelativePath = $Path
		$projectConfig.Branches = $projectConfig.Branches + @($branchInfo)
		SetProjectConfig -Project $Project -Config $projectConfig
	}
}

Register-ArgumentCompleter -CommandName New-GitWorktreeBranch -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ngwb New-GitWorktreeBranch
