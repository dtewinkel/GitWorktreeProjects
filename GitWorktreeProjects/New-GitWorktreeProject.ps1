function New-GitWorktreeProject
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
		[String] $SourceBranch,

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
		Push-Location
	}

	process
	{
		$projectConfig = GetProjectConfig -Project $Project -ErrorAction SilentlyContinue
		if($projectConfig)
		{
			throw "Project '${Project}' already exists"
		}
		$globalConfig = GetGlobalConfig -DefaultRootPath $TargetPath -DefaultSourceBranch $SourceBranch
		$TargetPath = $globalConfig.DefaultRootPath
		$SourceBranch = $globalConfig.DefaultSourceBranch
		$projectPath = Join-Path $TargetPath $Project
		if((Test-Path $projectPath) -and -not $Force.IsPresent)
		{
			throw "Folder ${projectPath} must not yet exist!"
		}
		$gitPath = Join-Path $projectPath .gitworktree
		if(-not (Test-Path $projectPath))
		{
			$null = mkdir $projectPath
		}
		$null = Set-Location $projectPath
		git clone $Repository $gitPath
		Set-Location $gitPath
		git checkout -b bare $SourceBranch

		$projectConfig = [ProjectConfig]::new()
		$projectConfig.RootPath = $projectPath
		$projectConfig.SourceBranch = $SourceBranch
		$projectConfig.GitPath = $gitPath
		$projectConfig.GitRepository = $Repository
		SetProjectConfig -Project $Project -ProjectConfig $projectConfig
	}

	end
	{
		Pop-Location
	}
}
