if($originalGitWorktreeConfigPath)
{
	$env:GitWorktreeConfigPath = $originalGitWorktreeConfigPath
}
else
{
	Remove-Item $env:GitWorktreeConfigPath
}
