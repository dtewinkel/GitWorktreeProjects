$errors = @()
$output = @()

try
{
	& 'git.exe' @args *>&1 | ForEach-Object {

		Write-Host $LASTEXITCODE

		if ($LASTEXITCODE -ne 0)
		{
			Write-host "-"
			if ($_ -is [System.Management.Automation.ErrorRecord])
			{
				Write-host "!"
				$errors += ([System.Management.Automation.ErrorRecord]$_).Exception.Message
			}
		}
		else
		{
			Write-host "+"
			$output += $_
		}
	}
}
catch
{
	$errors = @($_.Exception.Message)
}

Write-Host $?
Write-Host $LASTEXITCODE

if ($errors.Length -gt 0)
{
	$errorText = $errors -join "`n"
	Write-Host $errorText
	throw $errorText
}

$output -join "`n"
