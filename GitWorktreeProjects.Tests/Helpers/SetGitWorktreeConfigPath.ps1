[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	$Values
)

function SetEnvVar($varName, $value)
{
	$envVarName = "Env:${varName}"
	if($value)
	{
		if(Test-Path $envVarName)
		{
			Set-Item $envVarName $value
		}
		else
		{
			New-Item -Path $envVarName -Value $value
		}
	}
	else
	{
		if(Test-Path $envVarName)
		{
			Remove-Item $envVarName
		}
	}
}

SetEnvVar 'GitWorktreeConfigPath' $Values.GitWorktreeConfigPath
SetEnvVar 'USERPROFILE' $Values.USERPROFILE
SetEnvVar 'HOME' $Values.HOME
SetEnvVar 'HOMEDRIVE' $Values.HOMEDRIVE
SetEnvVar 'HOMEPATH' $Values.HOMEPATH
