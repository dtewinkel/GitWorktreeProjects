function Open-GitWorktree
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project = '.',

		[Parameter(Mandatory)]
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
				throw "Tool '$toolName' not found. Is it installed and registerd?"
			}
			& $toolFunction $projectConfig $tool.Parameters
		}
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Open-GitWorktree -ParameterName Worktree -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ogw Open-GitWorktree
