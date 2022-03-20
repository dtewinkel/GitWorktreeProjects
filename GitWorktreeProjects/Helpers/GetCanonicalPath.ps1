<#
Supports making a path canonnical accross reparse points.
#>
function GetCanonicalPath
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory)]
		[string] $CurrentPath,

		[Parameter()]
		[Switch] $ForCompare
	)

	Write-Verbose "CurrentPath: ${currentPath}"

	$item = Get-Item $currentPath

	$isReparsePoint = $item.Attributes.HasFlag([System.Io.FileAttributes]::ReparsePoint)

	if ($isReparsePoint -and $ForCompare.IsPresent)
	{
		$linkTarget = $item.LinkTarget
		if ($item.LinkType -eq 'Junction')
		{
			if ($linkTarget.StartsWith('Volume{'))
			{
				$accessPaths = @(Get-Partition |
						Where-Object AccessPaths -Contains "\\?\${linkTarget}" |
						Select-Object -ExpandProperty AccessPaths | Where-Object { $_ -ne "\\?\${linkTarget}" } |
						Sort-Object)
				if ($accessPaths.Length -eq 0)
				{
					break;
				}
				$item = Get-Item $accessPaths[0]
			}
			else
			{
				$item = Get-Item $linkTarget
			}
		}
		else
		{
			$item = Get-Item $linkTarget
		}
	}

	$leaf = $item.Name
	$parent = $item.Parent ?? $item.Directory

	if ($null -eq $parent)
	{
		Write-Verbose "At root: ${leaf}"
		return $leaf
	}


	$canonicalParent = GetCanonicalPath $parent.FullName -ForCompare:$ForCompare

	Write-Verbose "At canonicalParent: ${canonicalParent}"

	if (-not $item.PSIsContainer)
	{
		$leaf = $parent.GetFiles($leaf).Name
	}

	$canonicalPath = Join-Path $canonicalParent $leaf

	Write-Verbose "At canonicalPath: ${canonicalPath}"

	return $canonicalPath
}
