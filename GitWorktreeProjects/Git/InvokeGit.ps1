function InvokeGit
{
	$git ??= (Get-Command -Name git -CommandType Application | Select-Object -First 1).Path

	if (-not $git)
	{
		throw "git not found! Please make sure git is installed and can be found."
	}

	Write-Verbose "${git} ${args}"

	$tmpPath = [system.IO.Path]::GetTempPath()
	$fileGuid = [Guid]::NewGuid()
	$stdoutFile = Join-Path $tmpPath "${fileGuid}.stdout.txt"
	$stdoutTxt = $null
	$stderrFile = Join-Path $tmpPath "${fileGuid}.stderr.txt"
	$stderrTxt = $null
	try
	{
		$gitResult = Start-Process -FilePath $git -ArgumentList $args -Wait -NoNewWindow `
			-RedirectStandardError $stderrFile -RedirectStandardOutput $stdoutFile -PassThru

		if (Test-Path -Path $stderrFile)
		{
			$stderrTxt = Get-Content -Path $stderrFile -Raw
		}
		if (Test-Path -Path $stdoutFile)
		{
			$stdoutTxt = Get-Content -Path $stdoutFile -Raw
		}
	}
	finally
	{
		if (Test-Path -Path $stdoutFile)
		{
			Remove-Item -Path $stdoutFile
		}
		if (Test-Path -Path $stderrFile)
		{
			Remove-Item -Path $stderrFile
		}
	}
	$exitCode = $gitResult.ExitCode
	$success = $exitCode -eq 0
	return [PSCustomObject]@{
		GitExecutable = $git
		Arguments = $args
		Success = $success
		ExitCode = $exitCode
		OutputText = $stdoutTxt
		ErrorText = $stderrTxt
	}
}
