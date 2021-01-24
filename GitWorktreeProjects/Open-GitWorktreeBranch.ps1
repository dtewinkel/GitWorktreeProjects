function Open-GitWorktreeBranch
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $Project,

		[Parameter(Mandatory)]
		[String] $Branch,

		[Parameter()]
		[Switch] $NoTools
	)

	process
	{
		$config = GetProjectConfig -Project $Project
		$branchInfo = $config.Branches | Where-Object Name -EQ $Branch
		if (-not $branchInfo)
		{
			throw "Branch '${Branch}' not found!"
		}
		$fullPath = Join-Path $config.RootPath $branchInfo.RelativePath
		if (-not (Test-Path $fullPath))
		{
			throw "Path '${fullPath} for branch '${Branch}' not found"
		}
		Set-Location $fullPath
	}
}

Register-ArgumentCompleter -CommandName Open-GitWorktreeBranch -ParameterName Project -ScriptBlock ${function:ProjectArgumentCompleter}
Register-ArgumentCompleter -CommandName Open-GitWorktreeBranch -ParameterName Branch -ScriptBlock ${function:BranchArgumentCompleter}

New-Alias -Name ogwb Open-GitWorktreeBranch
