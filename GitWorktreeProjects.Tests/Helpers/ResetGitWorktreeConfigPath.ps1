if($originalGitWorktreeConfigPath)
{
	$env:GitWorktreeConfigPath = $originalGitWorktreeConfigPath
}
else
{
	if($env:GitWorktreeConfigPath)
	{
		Remove-Item env:GitWorktreeConfigPath
	}
}
