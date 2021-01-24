function New-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Repository,

		[Parameter()]
		[String] $TargetPath,

		[Parameter()]
		[String] $MainBranch,

		[Parameter()]
		[Switch] $Force
	)

	begin
	{
		$git = Get-Command git
		if(-not $git)
		{
			throw "git not found!"
		}
	}

	process
	{
		Push-Location
		$projectConfig = GetProjectConfig -Project $Project -ErrorAction SilentlyContinue
		if($projectConfig)
		{
			throw "Project '${Project}' already exists"
		}
		$globalConfig = GetGlobalConfig -DefaultRootPath $TargetPath -DefaultMainBranch $MainBranch
		$TargetPath = $globalConfig.DefaultRootPath
		$MainBranch = $globalConfig.DefaultMainBranch
		$projectPath = Join-Path $TargetPath $Project
		if((Test-Path $projectPath) -and -not $Force.IsPresent)
		{
			throw "Folder ${projectPath} must not yet exist!"
		}
		try
		{
			$gitPath = Join-Path $projectPath .gitworktree
			$null = mkdir $projectPath
			$null = Set-Location $projectPath
			git clone $Repository $gitPath
			Set-Location $gitPath
			git checkout -b bare $MainBranch

			$config = [ProjectConfig]::new()
			$config.RootPath = $projectPath
			$config.MainBranch = $MainBranch
			$config.GitPath = $gitPath
			SetProjectConfig -Project $Project -Config $config
		}
		finally
		{
			Pop-Location
		}
	}
}
