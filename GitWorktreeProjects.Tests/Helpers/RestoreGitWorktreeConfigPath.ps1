function ResetEnvVar($varName, $value)
{
	$envVarName = "Env:${varName}"
	if($value)
	{
		Set-Item $envVarName $value
	}
	else
	{
		if(Test-Path $envVarName)
		{
			Remove-Item $envVarName
		}
	}
}

ResetEnvVar GitWorktreeConfigPath $originalGitWorktreeConfigPath
ResetEnvVar USERPROFILE $originalUserProfile
ResetEnvVar HOME $originalHome
ResetEnvVar HOMEDRIVE $originalHomeDrive
ResetEnvVar HOMEPATH $originalHomePath
