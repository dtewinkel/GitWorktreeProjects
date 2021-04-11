function GetCurrentProject
{
	[OutputType([string])]
	[cmdletbinding()]
	param()

	$currentPath = (Get-Location).Path
	GetProjects |
		ForEach-Object {
			$fileName = "${PsItem}.project"
			GetConfigFile -FileName $fileName
		} |
		Where-Object {
			$destPath = (Get-Item $_.RootPath).FullName
			if($destPath)
			{
				$relPath = [System.IO.Path]::GetRelativePath($destPath, $currentPath)
				if([System.IO.Path]::IsPathRooted($relPath))
				{
					return $false
				}
				if($relPath -eq '.')
				{
					return $true
				}
				return $currentPath -eq (Join-Path $destPath $relPath)
			}
			return $false
		} |
		Select-Object -First 1 -ExpandProperty Name
}
