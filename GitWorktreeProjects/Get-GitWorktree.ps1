function Get-GitWorktree
{
<#
	.SYNOPSIS
		Get information about the working trees for a GitWorktree project.

	.DESCRIPTION
		Get information about some or all working trees for a GitWorktree project.

		By default Get-GitWorktree gets information about all working trees for the
		current project. Optionally a project can be specified with -Project.

		The set of working trees can be filtered with the -WorktreeFilter parameter.
		For the fitering the same wildcards can be used as for the -like operator.

		Tab completion is supported for the -Project and the -WorktreeFilter parameters.

	.INPUTS
		None. You cannot pipe objects to Get-GitWorktree.

	.OUTPUTS
		Worktree[]. An array of found Worktree objects. Can be empty.

	.EXAMPLE
		Get-GitWorktree

		Returns information about all working trees for the current project.

	.EXAMPLE
		Get-GitWorktree -Project Demo -WorktreeFilter ma*

		Returns information about all working trees where the name starts with 'ma'
		for the project 'Demo'.

	.EXAMPLE
		Get-GitWorktree . feature/*

		Returns information about all working trees for feature branches for the
		current project.

	.LINK
		about_Wildcards

		New-GitWorktree
		Open-GitWorktree
		Remove-GitWorktree

		Get-GitWorktreeProject
#>

	[cmdletbinding()]
	[OutputType([Worktree[]])]
	param(
		<#
		The project to get the information about the working trees for.

		Either specify the exact name of a project, or use wildcards to filter for a
		specific project. Exactly one project name must match the wildcard.
		For the fitering the same wildcards can be used as for the -like operator.
		If the project name does not exist, or the wilcard does not match exactly one
		project, then this will throw an error.

		The special project name '.' may be used to refer to the current project.
		This can be used when called from anywhere inside the folder structure of
		the current project.
		If project name '.' is used outside of the folder structure of the current
		project then an error will be thrown.

		Defaults to '.' to get the current project.

		Supports tab completion to select the project.
		#>
		[Parameter()]
		[ArgumentCompleter({ _gwp__ProjectArgumentCompleter -WordToComplete $args[2] })]
		[String] $Project = '.',

		<#
		Filter to select the working tree names for the project.

		Either specify the exact name of a working tree, or use wildcards to filter
		for a specific working tree or set of working trees. For the fitering the
		same wildcards can be used as for the -like operator.

		Defaults to '*' to get all working trees.

		Supports tab competion to select a working tree for the project.
		#>
		[Parameter()]
		[Alias("Filter")]
		[ArgumentCompleter({ _gwp__worktreeArgumentCompleter -WordToComplete $args[2] -FakeBoundParameters $args[4] })]
		[String] $WorktreeFilter = '*'
	)

	if ($Project -ne '.')
	{
		$projects = @(GetProjects $Project)

		if (-not $projects)
		{
			throw "No project found with name ${Project}. Make sure the name is correct."
		}

		if ($projects.Count -ne 1)
		{
			throw "Multiple projects found that match name ${Project}. Make sure the name is correct and that no wildcards are used that match more than one project."
		}
	}

	$projectConfig = GetProjectConfig -Project $Project -WorktreeFilter $WorktreeFilter -FailOnMissing

	Write-Output ([Worktree[]]($projectConfig.Worktrees) ?? @()) -NoEnumerate
}

New-Alias -Name ggw Get-GitWorktree
