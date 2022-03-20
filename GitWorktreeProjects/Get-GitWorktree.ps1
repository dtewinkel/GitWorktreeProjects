function Get-GitWorktree
{
<#
	.SYNOPSIS
		Get the worktrees for a GitWorktree project.

	.DESCRIPTION
		Get some or all worktrees for a GitWorktree project.

		By default Get-GitWorktree gets all worktrees for the current project.
		Optionally a project can be specified with -Project.

		The set of worktrees can be filtered with the -WorktreeFilter parameter.
		For the fitering the same wildcards can be used as for the -like operator.

		Tab completion is supported for the -Project and the -WorktreeFilter parameters.

	.INPUTS
		None. You cannot pipe objects to Get-GitWorktree.

	.OUTPUTS
		Worktree[]. An array of found Worktree objects. Can be empty.

	.EXAMPLE
		Get-GitWorktree

		Return all worktrees for the current project.

	.EXAMPLE
		Get-GitWorktree -Project Demo -WorktreeFilter ma*

		Return all worktrees where the name starts with 'ma' for the project 'Demo'.

	.EXAMPLE
		Get-GitWorktree . feature/*

		Return all worktrees for feature branches for the current project.

	.LINK
		about_Wildcards

	.LINK
		Get-GitWorktreeProject
#>

[cmdletbinding()]
	[OutputType([Worktree[]])]
	param(
		<#
		The project to get the worktrees for.

		The special project name '.' may be used to refer to the current project.
		This can be used when called from anywhere inside the folder structure of the current project.

		Defaults to the current project.
		Support tab completion to select the project.
		#>
		[Parameter()]
		[String] $Project = '.',

		<#
		Filter for the worktrees.

		Either specify an exact name of a worktree, or use wildcards to filter for a specific worktree or set of
		worktrees. For the fitering the same wildcards can be used as for the -like operator.

		Defaults to filter for all worktrees.
		Supports tab competion to select a worktree for the project.
		#>
		[Parameter()]
		[Alias("Filter")]
		[String] $WorktreeFilter = '*'
	)

	if ($Project -ne '.')
	{
		$projects = @(GetProjects $Project)
		if (-not $projects -or $projects.Length -ne 1)
		{
			throw "No project found with name ${Project}. Make sure the name is correct and that no wildcards are used that match more than one project."
		}
	}
	$projectConfig = GetProjectConfig -Project $Project -WorktreeFilter $WorktreeFilter -FailOnMissing
	Write-Output ([Worktree[]]($projectConfig.Worktrees) ?? @()) -NoEnumerate
}

Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktree -ParameterName WorktreeFilter -ScriptBlock ${function:WorktreeArgumentCompleter}

New-Alias -Name ggw Get-GitWorktree
