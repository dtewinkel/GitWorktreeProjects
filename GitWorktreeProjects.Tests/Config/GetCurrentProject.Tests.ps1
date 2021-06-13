[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "GetCurrentProject" {

	BeforeAll {

		. $PSScriptRoot/../Helpers/LoadAllModuleFiles.ps1 -ModuleFolder $ModuleFolder
	}

	It "Returns '<Result>' for current location '<Current>' " -ForEach @(
		@{
			Current = '/projects/p1/sources'
			Result = 'Project1'
		}
		@{
			Current = '/projects/p1'
			Result = 'Project1'
		}
		@{
			Current = '/projects/p1/'
			Result = 'Project1'
		}
		@{
			Current = '/projects/more/p2/'
			Result = 'Project2'
		}
		@{
			Current = '/demo/demo1'
			Result = 'Demo1'
		}
		@{
			Current = '/demo/demo'
			Result = 'Demo2'
		}
		@{
			Current = '/projects/more'
			Result = $null
		}
		@{
			Current = 'y:/projects/more/p2/'
			Result = $null
		}
	) {

		$projectItems = @(
			@{
				Name = "Demo1"
				RootPath = '/demo/demo1'
			}
			@{
				Name = "Demo2"
				RootPath = '/demo/demo'
			}
			@{
				Name = "Project1"
				RootPath = '/projects/p1'
			}
			@{
				Name = "Project2"
				RootPath = '/projects/more/p2'
			}
		)

		Mock Get-Location { @{ Path = $Current } } -Verifiable
		$projectNames = $projectItems | Select-Object -ExpandProperty Name
		Mock GetProjects { $projectNames } -Verifiable

		$allDone = $false
		foreach($projectItem in $projectItems)
		{
			if(-not $allDone)
			{
				$name = $projectItem.Name
				$rootPath = $projectItem.RootPath
				$parameterFilterScriptBlock = [Scriptblock]::Create("`$FileName -eq '${name}.project'")
				$resultScriptBlock = [Scriptblock]::Create("@{ Name = '$name';  RootPath = '$rootPath' }")
				Mock GetConfigFile $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock -Verifiable
				$parameterFilterScriptBlock = [Scriptblock]::Create("`$Path -eq '$rootPath'")
				$resultScriptBlock = [Scriptblock]::Create("@{ FullName = '$rootPath' }")
				Mock Get-Item $resultScriptBlock -ParameterFilter $parameterFilterScriptBlock -Verifiable
				Mock Join-Path { "${Path}/${ChildPath}" -replace '\\', '/' }
				$allDone = $Result -eq $projectItem.Name
			}
		}

		$project = GetCurrentProject

		Should -InvokeVerifiable
		$project | Should -Be $_.Result
	}
}
