function Remove-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $Branch,

		[Parameter()]
		[Switch] $NoTools
	)

	process
	{
	}
}
