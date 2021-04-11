function Get-GitWorktree
{
	[cmdletbinding()]
	[OutputType([Worktree[]])]
	param(
		[Parameter()]
		[String] $Project = '.cccccctlrbnngihrkffvbnjifintjbgldvdueubfilvd
		',

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	if ($Project -ne '.')
	{
		$projects = @(GetProjects $Project)
		if(-not $projects -or $projects.Length -ne 1)
		{
			throw "No project found with name ${Project}. Make sure the name is correct and that no wildcards are used that match more than one project."
		}
	}
	(GetProjectConfig -Project $Project -WorktreeFilter $WorktreeFilter -FailOnMissing).Worktrees
}

Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName WorktreeFilter -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ggw Get-GitWorktree
