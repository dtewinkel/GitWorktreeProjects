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
		if($projectConfig -and -not $Force.IsPresent)
		{
			throw "Project '${Project}' already exists"
		}
		$globalConfig = GetGlobalConfig

		if(-not $TargetPath)
		{
			$TargetPath = $globalConfig.DefaultRootPath
		}
		if (-not (Test-Path -Path $TargetPath))
		{
				throw "TargetPath '${TargetPath}' must exist!"
		}

		if(-not $SourceBranch)
		{
			$SourceBranch = $globalConfig.DefaultSourceBranch
		}

		$projectPath = Join-Path $TargetPath $Project
		if((Test-Path $projectPath) -and -not $Force.IsPresent)
		{
			throw "Folder ${projectPath} must not yet exist!"
		}

		$gitPath = Join-Path $projectPath .gitworktree
		if(-not (Test-Path $projectPath))
		{
			$null = New-Item -ItemType directory -Path $projectPath
		}
		# Make sure get the proper canonical path.
		$projectPath = (Get-Item $projectPath).FullName
		Set-Location $projectPath
		git clone $Repository $gitPath
		Set-Location $gitPath
		git checkout -b bare $SourceBranch

		$projectConfig = [Project]::new()
		$projectConfig.Name = $Project
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

New-Alias -Name ngwp New-GitWorktreeProject
