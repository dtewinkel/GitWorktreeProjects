function GetConfigFile
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[string] $FileName,

		[Parameter()]
		[string] $SchemaVersion = 1
	)

	process
	{
		$filePath = GetConfigFilePath -ChildPath $FileName

		if(-not (Test-Path $filePath))
		{
			return $null
		}
		$content = Get-Content -Raw -Path $filePath
		try {
			$converted = $content | ConvertFrom-Json -NoEnumerate -ErrorAction SilentlyContinue
		}
		catch
		{
			$converted = $null
		}
		if(-not $converted)
		{
			throw "Could not convert file '${fileName}' (${filePath})! Is it valid JSON?"
		}
		$foundSchemaVersion = $converted.SchemaVersion
		if($null -eq $foundSchemaVersion)
		{
			throw "Schema version is not set for file '${fileName}' (${filePath})."
		}
		if($foundSchemaVersion -ne $SchemaVersion)
		{
			throw "Schema version '${foundSchemaVersion}' is not supported for file '${fileName}' (${filePath})."
		}
		$converted
	}
}
