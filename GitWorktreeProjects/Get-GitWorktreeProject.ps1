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

	if ($ProjectFilter -eq '.')
	{
		GetProjectConfig -Project $ProjectFilter -WorktreeFilter $WorktreeFilter -FailOnMissing
	}
	else
	{
		foreach ($project in (GetProjects $ProjectFilter))
		{
			GetProjectConfig -Project $project -WorktreeFilter $WorktreeFilter -FailOnMissing
		}
	}
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName ProjectFilter -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName WorktreeFilter -ScriptBlock ${function:WorktreeFilterArgumentCompleter}

New-Alias -Name ggwp Get-GitWorktreeProject
