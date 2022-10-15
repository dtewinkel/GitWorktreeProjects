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
		$rootPath = __GitWorktree_GetFromEnv 'USERPROFILE'
		if(-not $rootPath)
		{
			$rootPath = "$(__GitWorktree_GetFromEnv 'HOMEDRIVE')$(__GitWorktree_GetFromEnv 'HOMEPATH')"
		}
		if(-not $rootPath)
		{
			$rootPath = __GitWorktree_GetFromEnv 'HOME'
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
