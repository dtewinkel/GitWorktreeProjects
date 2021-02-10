function Set-GitWorktreeConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $DefaultRoot,

		[Parameter()]
		[String] $DefaultBranch
	)

	process
	{
		GetGlobalConfig -DefaultRootPath $DefaultRoot -DefaultSourceBranch $DefaultBranch -SaveChanges
	}
}
