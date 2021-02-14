function Get-GitWorktreeProject
{
	[cmdletbinding()]
	param(
		[Parameter()]
		[String] $ProjectFilter = '*',

		[Parameter()]
		[String] $WorktreeFilter = '*'
	)

	process
	{
		foreach($project in (GetProjects $ProjectFilter))
		{
			$projectConfig = GetProjectConfig -Project $project -WorktreeFilter $WorktreeFilter
			[Project]::FromProjectConfig($project, $projectConfig)
		}
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName Filter -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ggwp Get-GitWorktreeProject
