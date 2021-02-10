class GlobalConfig
{
	[string] $DefaultRootPath = $env:HOME
	[string] $DefaultSourceBranch = 'main'

	static [GlobalConfig] FromJsonFile([string] $jsonPath)
	{
		if(-not (Test-Path $jsonPath))
		{
			return $null
		}
		$converted = Get-Content -Raw -Path $jsonPath | ConvertFrom-Json
		if(-not $converted)
		{
			return $null
		}
		$globalConfig = [GlobalConfig]::new()
		if($null -ne $converted.DefaultRootPath)
		{
			$globalConfig.DefaultRootPath = $converted.DefaultRootPath
		}
		if($null -ne $converted.DefaultSourceBranch)
		{
			$globalConfig.DefaultSourceBranch = $converted.DefaultSourceBranch
		}
		return $globalConfig
	}
}
