function GetCurrentProject
{
		$currentPath = (Get-Location).Path
		GetProjects |
				ForEach-Object {
					$fileName = "${PsItem}.project"
					GetConfigFile -FileName $fileName
				} |
				Where-Object {
					$destPath = (Get-Item $_.RootPath).FullName
					$destPath -and $currentPath.StartsWith($destPath)
				} |
				Select-Object -First 1 -ExpandProperty Name
}
