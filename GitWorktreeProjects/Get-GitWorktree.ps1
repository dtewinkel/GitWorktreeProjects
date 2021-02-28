function Get-GitWorktree
{
	[cmdletbinding()]
	[OutputType([WorktreeConfig[]])]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	process
	{
		$projectConfig = GetProjectConfig -Project $Project

		$projectConfig.Worktrees | Where-Object Name -Like $WorktreeFilter
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Fileter -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ggw Get-GitWorktree
