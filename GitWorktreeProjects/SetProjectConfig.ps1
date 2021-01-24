function SetProjectConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project,

		[Parameter()]
		[ProjectConfig] $Config
	)

	process
	{
		$configFilePath = Join-Path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath "${Project}.project"
		$config | ConvertTo-Json | Out-File $configFilePath -Encoding utf8BOM
	}
}
