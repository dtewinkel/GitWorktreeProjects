function AssertGitSuccess
{
	[cmdletbinding()]
	param(
		[Parameter(Mandatory, ValueFromPipeline)]
		$GitResult
	)

	if(-not $GitResult.Success)
	{
		$messageFromGit = $GitResult.ErrorText ?? $GitResult.OutputText
		$errorMessage = `
@"
Git failed with exit code $($GitResult.Exitcode):

${messageFromGit}

Command line used: ['$($GitResult.GitExecutable)' $($GitResult.Arguments)]
"@
		throw $errorMessage
	}

	$GitResult.OutputText ?? $GitResult.ErrorText
}
