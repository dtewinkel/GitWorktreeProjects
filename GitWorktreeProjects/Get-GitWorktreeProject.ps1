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
}

Register-ArgumentCompleter -CommandName Get-GitWorktreeProject -ParameterName Filter -ScriptBlock ${function:ProjectArgumentCompleter}

New-Alias -Name ggwp Get-GitWorktreeProject
