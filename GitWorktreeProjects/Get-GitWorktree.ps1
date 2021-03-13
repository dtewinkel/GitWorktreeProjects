﻿function Get-GitWorktree
{
	[cmdletbinding()]
	[OutputType([Worktree[]])]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	process
	{
		(GetProjectConfig -Project $Project -WorktreeFilter $WorktreeFilter -FailOnMissing).Worktrees
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Fileter -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ggw Get-GitWorktree
