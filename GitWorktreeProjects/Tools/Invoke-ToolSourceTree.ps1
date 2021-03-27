function Invoke-ToolSourceTree
{
	[cmdletbinding()]
	param(
		# Project with single or no worktree.
		[Parameter(mandatory)]
		[Project] $Project,

		[Parameter()]
		[string[]] $ToolParameters
	)

	$probePaths = "${env:APPDATA}/../Local/SourceTree/SourceTree.exe", "${env:ProgramFiles(x86)}/Atlassian/Sourcetree/SourceTree.exe"
	foreach($sourceTree in $probePaths)
	{
		if(Test-Path $sourceTree)
		{
			& $sourceTree -f (Resolve-Path .)
			return
		}
	}
	throw "SourceTree.exe not found"
}
