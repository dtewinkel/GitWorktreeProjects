<#

#>
Function New-GitWorktreeProject
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
		[ArgumentCompletions('main', 'develop', 'trunk', 'root', 'dev', 'primary', 'master')]
		[String] $SourceBranch,

		[Parameter()]
		[Switch] $Force
	)

	Push-Location

	try
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
			if ($Force.IsPresent)
			{
				mkdir $TargetPath -Force
			}
			else
			{
				throw "TargetPath '${TargetPath}' must exist!"
			}
		}

		$projectPath = Join-Path $TargetPath $Project
		# Make sure get the proper canonical path.
		if((Test-Path $projectPath) -and -not $Force.IsPresent)
		{
			throw "Folder '${projectPath}' must not yet exist!"
		}
		if(-not (Test-Path $projectPath))
		{
			$null = New-Item -ItemType directory -Path $projectPath
		}
		$projectPath = (Get-Item $projectPath).FullName

		$gitPath = Join-Path $projectPath .gitworktree

		if(-not $SourceBranch)
		{
			$SourceBranch = $globalConfig.DefaultSourceBranch
		}

		Set-Location $projectPath
		InvokeGit clone $Repository $gitPath | AssertGitSuccess | Out-Null

		Set-Location $gitPath
		InvokeGit checkout -b bare $SourceBranch | AssertGitSuccess | Out-Null

		$projectConfig = [Project]::new()
		$projectConfig.Name = $Project
		$projectConfig.RootPath = $projectPath
		$projectConfig.SourceBranch = $SourceBranch
		$projectConfig.GitPath = $gitPath
		$projectConfig.GitRepository = $Repository
		SetProjectConfig -Project $Project -ProjectConfig $projectConfig
	}
	finally
	{
		Pop-Location
	}
}

New-Alias -Name ngwp New-GitWorktreeProject
