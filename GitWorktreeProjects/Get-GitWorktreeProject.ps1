function Get-GitWorktreeProject
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $Filter = '*'
	)

	process
	{
		foreach($project in (GetProjects ${Filter}))
		{
			$projectConfig = GetProjectConfig -Project $project
			[Project]::FromProjectConfig($project, $projectConfig)
		}
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName Filter -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ggwp Get-GitWorktreeProject
