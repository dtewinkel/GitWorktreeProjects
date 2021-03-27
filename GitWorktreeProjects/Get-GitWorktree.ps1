function Get-GitWorktree
{
	[cmdletbinding()]
	[OutputType([Worktree[]])]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	(GetProjectConfig -Project $Project -WorktreeFilter $WorktreeFilter -FailOnMissing).Worktrees
}

Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName WorktreeFilter -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ggw Get-GitWorktree
