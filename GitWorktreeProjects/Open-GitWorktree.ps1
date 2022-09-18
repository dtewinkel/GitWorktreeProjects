function Open-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter @args })]
		[String] $Project = '.',

		[Parameter(Mandatory)]
		[ArgumentCompleter({ _gwp__worktreeArgumentCompleter @args })]
		[String] $Worktree,

		[Parameter()]
		[Switch] $NoTools
	)

	$projectConfig = GetProjectConfig -Project $Project -WorktreeFilter $Worktree -WorktreeExactMatch -FailOnMissing
	$worktreeConfig = $projectConfig.Worktrees[0]
	$fullPath = Join-Path $projectConfig.RootPath $worktreeConfig.RelativePath
	if (-not (Test-Path $fullPath))
	{
		$projectName = $projectConfig.Name
		throw "Path '${fullPath}' for worktree '${Worktree}' in project '${projectName}' not found!"
	}
	Set-Location $fullPath

	$tools = $worktreeConfig.Tools

	if (-not $NoTools.IsPresent)
	{
		foreach ($tool in $tools)
		{
			$toolName = $tool.Name
			$toolFunction = Get-Item function:Invoke-Tool$toolName -ErrorAction SilentlyContinue
			if (-not $toolFunction)
			{
				$message = "Tool '${toolName}' not found. Is it installed and registerd?"
				throw $message
			}
			& $toolFunction $projectConfig $tool.Parameters
		}
	}
}

New-Alias -Name ogw Open-GitWorktree
