# based on https://gist.github.com/indented-automation/26c637fb530c4b168e62c72582534f5b

[CmdletBinding()]
param (
	# Filter results by command name.
	[Parameter(Mandatory)]
	[String]$CommandName,

	# Filter results by parameter name.
	[Parameter(Mandatory)]
	[String]$ParameterName
)

$getExecutionContextFromTLS = [PowerShell].Assembly.GetType('System.Management.Automation.Runspaces.LocalPipeline').GetMethod(
	'GetExecutionContextFromTLS',
	[System.Reflection.BindingFlags]'Static, NonPublic'
)

$internalExecutionContext = $getExecutionContextFromTLS.Invoke(
	$null,
	[System.Reflection.BindingFlags]'Static, NonPublic',
	$null,
	$null,
	$psculture
)

$argumentCompletersProperty = $internalExecutionContext.GetType().GetProperty(
	'CustomArgumentCompleters',
	[System.Reflection.BindingFlags]'NonPublic, Instance'
)

$argumentCompleters = $argumentCompletersProperty.GetGetMethod($true).Invoke(
	$internalExecutionContext,
	[System.Reflection.BindingFlags]'Instance, NonPublic, GetProperty',
	$null,
	@(),
	$psculture
)

foreach ($completer in $argumentCompleters.Keys)
{
	$name, $parameter = $completer -split ':'

	if ($name -eq $CommandName -and $parameter -eq $ParameterName)
	{
		return $true
	}
}

return $false
