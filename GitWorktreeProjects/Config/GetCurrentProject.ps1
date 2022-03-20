function GetCurrentProject
{
	[OutputType([string])]
	[cmdletbinding()]
	param()

	function IsChildPathOf($CurrentPath, $RootPath)
	{
		$destPath = (Get-Item -Path $RootPath).FullName
		$relPath = [System.IO.Path]::GetRelativePath($destPath, $CurrentPath)
		if ([System.IO.Path]::IsPathRooted($relPath))
		{
			return $false
		}
		if ($relPath -eq '.')
		{
			return $true
		}
		return $CurrentPath -eq (Join-Path $destPath $relPath)
	}

	$currentPath = (Get-Location).Path
	foreach ($projectName in GetProjects)
	{
		Write-Verbose $projectName
		$fileName = "${projectName}.project"
		$config = GetConfigFile -FileName $fileName
		Write-Verbose ($config | ConvertTo-Json -Depth 5)
		if (IsChildPathOf $currentPath $config.RootPath)
		{
			return $config.Name
		}
	}
}
