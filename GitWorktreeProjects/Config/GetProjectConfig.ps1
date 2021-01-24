function GetProjectConfig
{
	[OutputType([ProjectConfig])]
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project
	)

	process
	{
		$configFilePath = Join-Path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath "${Project}.project"
		if (-not (Test-Path $configFilePath))
		{
			throw "Project Config File '${configFilePath}' for project '${Project}' not found! Use New-GitWorktreeProject to create it."
		}
		[ProjectConfig](Get-Content -Path $configFilePath | ConvertFrom-Json)
	}
}
