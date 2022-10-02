function Invoke-ToolWindowTitle
{
	[cmdletbinding()]
	param(
		# Project with single or no working tree.
		[Parameter(mandatory)]
		[Project] $Project,

		[Parameter()]
		[string[]] $ToolParameters
	)

	$projectName = $Project.Name
	$worktree = $Project.Worktrees[0]
	$worktreeName = $worktree.Name

	$title = "${toolParameters}[${projectName}] ${worktreeName}"
	$host.ui.RawUI.WindowTitle = $title
}
