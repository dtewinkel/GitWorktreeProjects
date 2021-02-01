$originalGitWorktreeConfigPath = $env:GitWorktreeConfigPath
$env:GitWorktreeConfigPath = "TestDrive:/.gitworktree"
if(Test-Path $env:GitWorktreeConfigPath)
{
	Remove-Item -Recurse -Force $env:GitWorktreeConfigPath
}
mkdir $env:GitWorktreeConfigPath
