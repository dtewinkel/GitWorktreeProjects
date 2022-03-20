function InvokeGit
{
	$errors = @()
	$output = @()

	$script:git ??= (Get-Command -Name git -CommandType Application | Select-Object -First 1).Path

	if(-not $script:git)
	{
		throw "git not found! Please make sure git is installed and can be found."
	}

	Write-Verbose "executable for git found at: ${git}"

	try
	{
		& $script:git @args *>&1 | ForEach-Object {

			if ($_ -is [System.Management.Automation.ErrorRecord])
			{
				$errors += ([System.Management.Automation.ErrorRecord]$_).Exception.Message
			}
			else
			{
				$output += $_
			}
		}
	}
	catch
	{
		$errors = @($_.Exception.Message)
	}

	if ($errors.Length -gt 0)
	{
		$errorText = $errors -join "`n"
		throw $errorText
	}

	$output -join "`n"
}
