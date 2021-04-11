class GlobalConfigFile
{
	[int] $SchemaVersion
	[string] $DefaultRootPath
	[string] $DefaultSourceBranch
	[string[]] $DefaultTools
}

class GlobalConfig
{
	[string] $DefaultRootPath
	[string] $DefaultSourceBranch = 'main'
	[string[]] $DefaultTools

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
		$this.DefaultTools = [string[]]@('WindowTitle')
	}

	static [GlobalConfig] FromFile([GlobalConfigFile] $configFile)
	{
		$globalConfig = [GlobalConfig]::new()
		$globalConfig.DefaultRootPath = $configFile.DefaultRootPath
		$globalConfig.DefaultSourceBranch = $configFile.DefaultSourceBranch
		$globalConfig.DefaultTools = $configFile.DefaultTools

		return $globalConfig
	}

	[GlobalConfigFile] ToFile()
	{
		$configFile = [GlobalConfigFile]::new()
		$configFile.SchemaVersion = 1
		$configFile.DefaultRootPath = $this.DefaultRootPath
		$configFile.DefaultSourceBranch = $this.DefaultSourceBranch
		$configFile.DefaultTools = $this.DefaultTools

		return $configFile
	}
}
