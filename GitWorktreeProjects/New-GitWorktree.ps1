function New-GitWorktree
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

		if (-not $Commitish -and -not $Path -and -not $Name -and -not $NewBranch)
		{
			throw "At lease one of -Commitish, -Path, -NewBranch, and -Name must be given."
		}
	}

	process
	{
		$projectConfig = GetProjectConfig -Project $Project

		if (-not $Commitish)
		{
			$Commitish = $projectConfig.SourceBranch
		}
		if (-not $Name -and $NewBranch)
		{
			$Name = $NewBranch
		}
		if (-not $Name)
		{
			$Name = $Commitish
		}
		if (-not $Path)
		{
			$Path = $Name
		}

		$branchInfo = $projectConfig.Worktrees | Where-Object Name -EQ $Name
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
		if($LastExitCode -ne 0)
		{
			throw "Git failed with exit code ${LastExitCode}."
		}
		if (Test-Path $branchPath)
		{
			Set-Location $branchPath
			$branchInfo = [BranchInfo]::new()
			$branchInfo.Name = $Name
			$branchInfo.InitialCommitish = $Commitish
			$branchInfo.RelativePath = $Path
			$projectConfig.Worktrees = $projectConfig.Worktrees + @($branchInfo)
			SetProjectConfig -Project $Project -Config $projectConfig
		}
		else
		{
			throw "Failed to create folder '${branchPath}'. Worktree not created"
		}
	}
}

Register-ArgumentCompleter -CommandName New-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ngw New-GitWorktree
