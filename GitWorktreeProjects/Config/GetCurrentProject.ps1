function GetCurrentProject
{
		$currentPath = (Get-Location).Path
		GetProjects |
				ForEach-Object {
					$fileName = "${PsItem}.project"
					GetConfigFile -FileName $fileName
				} |
				Where-Object { $currentPath.StartsWith((Get-Item $_.RootPath).FullName) } |
				Select-Object -First 1 -ExpandProperty Name
}
