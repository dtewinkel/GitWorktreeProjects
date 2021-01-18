function New-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter()]
		[String] $Branch
	)

	process
	{
	}
}

New-alias -Name ngwb New-GitWorktreeBranch
