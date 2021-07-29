function __GitWorktree_GetFromEnv($VarName)
{
	(Get-Item -Path "Env:${VarName}" -ErrorAction SilentlyContinue).Value
}
