function Get-GitWorktreeProject
{
<#
	.SYNOPSIS
		Get infromation about GitWorktree projects.

	.DESCRIPTION
		Get some or all GitWorktree projects. Results can be fitered bij project name and bij working tree name.
		When filtering by working tree name, only projects that have working trees matching the filter will be returned.

	.INPUTS
		None. You cannot pipe objects to Get-GitWorktreeProject.

	.OUTPUTS
		Project[]. An array of found Project objects. Can be empty.

	.EXAMPLE
		Get-GitWorktreeProject

		Return all GitWorktree projects with all their working trees.

	.EXAMPLE
		Get-GitWorktreeProject -WorktreeFilter main

		Return all GitWorktree projects that have a working tree called 'main'.

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
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter -WordToCompete $args[2] })]
		[String] $ProjectFilter = '*',

		<#
		Filter to select the working tree names for the projects.

		Either specify an exact name of a working tree, or use wildcards to filter for a specific working tree or set of
		working trees. For the fitering the same wildcards can be used as for the -like operator.

		Defaults to '*' to get all working trees.

		If the WorktreeFilter has another value than '*', then only projects will be returned that have at least one
		working tree name matching the filter.

		Supports tab competion to select a working tree.
		#>
		[Parameter()]
		[ArgumentCompleter({ _gwp__worktreeFilterArgumentCompleter -WordToCompete $args[2] -FakeBoundParameters $args[4] })]
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
