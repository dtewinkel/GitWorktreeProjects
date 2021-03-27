function Invoke-ToolVsCode
{
	[cmdletbinding()]
	param(
		# Project with single or no worktree.
		[Parameter(mandatory)]
		[Project] $Project,

		[Parameter()]
		[string[]] $ToolParameters
	)

	code .
}
