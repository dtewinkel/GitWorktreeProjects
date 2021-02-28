class GlobalConfigFile
{
	[int] $SchemaVersion
	[string] $DefaultRootPath
	[string] $DefaultSourceBranch
}

class GlobalConfig
{
	[string] $DefaultRootPath
	[string] $DefaultSourceBranch = 'main'

	GlobalConfig()
	{
		$rootPath = $env:UserProfile
		if(-not $rootPath)
		{
			$rootPath = "${env:HOMEDRIVE}${env:HOMEPATH}"
		}
		if(-not $rootPath)
		{
			$rootPath = $env:HOME
		}
		if(-not $rootPath)
		{
			$rootPath = '/'
		}
		$this.DefaultRootPath = $rootPath
	}

	static [GlobalConfig] FromFile([GlobalConfigFile] $configFile)
	{
		$globalConfig = [GlobalConfig]::new()
		$globalConfig.DefaultRootPath = $configFile.DefaultRootPath
		$globalConfig.DefaultSourceBranch = $configFile.DefaultSourceBranch
		return $globalConfig
	}

	[GlobalConfigFile] ToFile()
	{
		$configFile = [GlobalConfigFile]::new()
		$configFile.SchemaVersion = 1
		$configFile.DefaultRootPath = $this.DefaultRootPath
		$configFile.DefaultSourceBranch = $this.DefaultSourceBranch
		return $configFile
	}
}
