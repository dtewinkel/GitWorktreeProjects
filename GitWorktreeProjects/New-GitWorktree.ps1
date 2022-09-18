function New-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter @args })]
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

	if (-not $Commitish -and -not $Path -and -not $Name -and -not $NewBranch)
	{
		throw "At lease one of -Commitish, -Path, -NewBranch, and -Name must be given."
	}

	$projectConfig = GetProjectConfig -Project $Project -FailOnMissing
	$projectName = $projectConfig.Name

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

	$worktree = $projectConfig.Worktrees | Where-Object Name -EQ $Name
	if ($worktree)
	{
		throw "Worktree with name '${Name}' already exists!"
	}

	Set-Location -Path $projectConfig.GitPath
	$worktreePath = Join-Path $projectConfig.RootPath $Path
	if (Test-Path $worktreePath)
	{
		throw "Worktree path '${worktreePath}' already exists!"
	}

	if ($NewBranch)
	{
		$exitingBranch = git branch -l $NewBranch
		if ($exitingBranch)
		{
			throw "Branch '${NewBranch}' already exists!"
		}
		git worktree add -b $NewBranch $worktreePath $Commitish
	}
	else
	{
		git worktree add $worktreePath $Commitish
	}
	if ($LastExitCode -ne 0)
	{
		throw "Git failed with exit code ${LastExitCode}."
	}
	if (Test-Path $worktreePath)
	{
		Set-Location $worktreePath
		$worktree = [Worktree]::new()
		$worktree.Name = $Name
		$worktree.InitialCommitish = $Commitish
		$worktree.RelativePath = $Path
		$worktree.NewBranch = $NewBranch
		$projectConfig.Worktrees = $projectConfig.Worktrees + @($worktree)
		SetProjectConfig -Project $projectName -ProjectConfig $projectConfig
	}
	else
	{
		throw "Failed to create folder '${branchPath}'. Worktree not created"
	}
}

New-Alias -Name ngw New-GitWorktree
