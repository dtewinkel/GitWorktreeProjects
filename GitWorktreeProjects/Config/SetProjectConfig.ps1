function SetProjectConfig
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Project,

		[Parameter()]
		[Project] $ProjectConfig
	)

	$configPath = GetConfigFilePath
	if(-not (Test-Path $configPath))
	{
		$null = New-Item -ItemType Directory -Path $configPath
	}
	$configFile = GetConfigFilePath -ChildPath "${Project}.project"

	$ProjectConfig.ToFile() | ConvertTo-Json | Out-File -FilePath $configFile -Encoding utf8BOM
}
