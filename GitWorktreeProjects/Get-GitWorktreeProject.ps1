function Get-GitWorktreeProject
{
<#
	.SYNOPSIS
		Get infromation about GitWorktree projects.

	.DESCRIPTION
		Get some or all GitWorktree projects. Results can be fitered bij project name and bij worktree name.
		When filtering by worktree name, only projects that have worktrees matching the filter will be returned.

	.INPUTS
		None. You cannot pipe objects to Get-GitWorktreeProject.

	.OUTPUTS
		Project[]. An array of found Project objects. Can be empty.

	.EXAMPLE
		Get-GitWorktreeProject

		Return all GitWorktree projects with all their worktrees.

	.EXAMPLE
		Get-GitWorktreeProject -WorktreeFilter main

		Return all GitWorktree projects that have a worktree called 'main'.

	.EXAMPLE
		Get-GitWorktreeProject -ProjectFilter demo

		Return GitWorktree project 'demo'.

	.LINK
		about_Wildcards

	.LINK
		Get-GitWorktree
#>

	[cmdletbinding()]
	[OutputType([Project[]])]
	param(
		<#
		Filter to select the project names.

		Either specify an exact name of a project, or use wildcards to filter for a specific project or set of
		projects. For the fitering the same wildcards can be used as for the -like operator.

		Defaults to '*' to get all projects.

		Supports tab competion to select specific project.
		#>
		[Parameter()]
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter @args })]
		[String] $ProjectFilter = '*',

		<#
		Filter to select the worktrees names for the projects.

		Either specify an exact name of a worktree, or use wildcards to filter for a specific worktree or set of
		worktrees. For the fitering the same wildcards can be used as for the -like operator.

		Defaults to '*' to get all worktrees.

		If the WorktreeFilter has another value than '*', then only projects will be returned that have at least one
		worktree name matching the filter.

		Supports tab competion to select a worktree.
		#>
		[Parameter()]
		[ArgumentCompleter({ _gwp__worktreeFilterArgumentCompleter @args })]
		[String] $WorktreeFilter = '*'
	)

	if ($ProjectFilter -eq '.')
	{
		GetProjectConfig -Project $ProjectFilter -WorktreeFilter $WorktreeFilter -FailOnMissing
	}
	else
	{
		foreach ($project in (GetProjects $ProjectFilter))
		{
			GetProjectConfig -Project $project -WorktreeFilter $WorktreeFilter -FailOnMissing
		}
	}
}

New-Alias -Name ggwp Get-GitWorktreeProject
