function Get-GitWorktreeProject
{
	[cmdletbinding()]
	[OutputType([Project[]])]
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
			GetProjectConfig -Project $project -WorktreeFilter $WorktreeFilter
		}
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName Filter -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ggwp Get-GitWorktreeProject
