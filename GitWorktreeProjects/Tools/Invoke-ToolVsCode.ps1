function Invoke-ToolVsCode
{
	[cmdletbinding()]
	param(
		# Project with single or no working tree.
		[Parameter(mandatory)]
		[Project] $Project,

		[Parameter()]
		[string[]] $ToolParameters
	)

	code .
}
