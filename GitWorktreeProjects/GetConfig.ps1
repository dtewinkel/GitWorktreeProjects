
class GlobalConfig
{
	[string] $DefaultRootPath
	[string] $DefaultBranch
	[string[]] $DefaultTools
}

function GetConfig
{
	[OutputType([GlobalConfig])]
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[String] $DefaultRootPath,

		[Parameter()]
		[String] $DefaultBranch
	)

	process
	{
		$configFilePath = join-path -Path ${HOME} -ChildPath .gitworktree -AdditionalChildPath .global.json
		[GlobalConfig](get-content -Path $configFilePath | ConvertFrom-Json)
	}
}
