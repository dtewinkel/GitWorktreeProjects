function ValidateGit
{
	[cmdletbinding()]
	param(
	)

	$git = Get-Command git
	if(-not $git)
	{
		throw "git not found! Please make sure git is installed and can be found."
	}
}
