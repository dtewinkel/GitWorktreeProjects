[CmdletBinding()]
param (
		[Parameter()]
		[string]
		$ModuleFolder
)

Describe "New-GitWorktreeProject" {

	BeforeAll {
		Push-Location
		. $PSScriptRoot/Helpers/LoadModule.ps1 -ModuleFolder $ModuleFolder

		$projectName = "MyProject"
		$repository = "https://my.repository/"
	}

	BeforeEach {
		# the following should be called always:
		Mock ValidateGit -ModuleName GitWorktreeProjects -Verifiable
		Mock Push-Location -ModuleName GitWorktreeProjects -Verifiable
		Mock Pop-Location -ModuleName GitWorktreeProjects -Verifiable
		Mock New-Item -ModuleName GitWorktreeProjects
	}

	It "should have the right parameters" {
		$command = Get-Command New-GitWorktreeProject

		$command | Should -HaveParameter Project -Mandatory
		$command | Should -HaveParameter Repository -Mandatory
		$command | Should -HaveParameter TargetPath
		$command | Should -HaveParameter SourceBranch
		$command | Should -HaveParameter Force
	}

	It "Validates project does not already exist" {

		Mock GetProjectConfig { @{ Name = $projectName } } -ModuleName GitWorktreeProjects -ParameterFilter { $Project -eq $projectName } -Verifiable

		{ New-GitWorktreeProject -Project $projectName -Repository $repository } | Should -Throw "Project '${projectName}' already exists"

		Should -InvokeVerifiable
	}

	It "Validates Target path does exist with user specified path" {

		$targetPath = '/my/target/path'
		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects -ParameterFilter { $Project -eq $projectName } -Verifiable
		Mock GetGlobalConfig { @{ DefaultRootPath = '/default/root' } } -ModuleName GitWorktreeProjects -Verifiable
		Mock Test-Path { $false } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $targetPath } -Verifiable

		{ New-GitWorktreeProject -Project $projectName -Repository $repository -TargetPath $targetPath } | Should -Throw "TargetPath '${targetPath}' must exist!"

		Should -InvokeVerifiable
	}

	It "Validates Target path does exist with default path" {

		$defaultPath = '/default/root'
		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects -ParameterFilter { $Project -eq $projectName } -Verifiable
		Mock GetGlobalConfig { @{ DefaultRootPath = $defaultPath } } -ModuleName GitWorktreeProjects -Verifiable
		Mock Test-Path { $false } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $defaultPath } -Verifiable

		{ New-GitWorktreeProject -Project $projectName -Repository $repository } | Should -Throw "TargetPath '${defaultPath}' must exist!"

		Should -InvokeVerifiable
	}

	It "Validates Project path does not exist" {

		$defaultPath = '/default/root'
		$projectPath = "${defaultPath}/${projectName}"
		$canonicalProjectPath = "${defaultPath}/${projectName}/"
		Mock GetProjectConfig { } -ModuleName GitWorktreeProjects -ParameterFilter { $Project -eq $projectName } -Verifiable
		Mock GetGlobalConfig { @{ DefaultRootPath = $defaultPath } } -ModuleName GitWorktreeProjects -Verifiable
		Mock Test-Path { $true } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $defaultPath } -Verifiable
		Mock Join-Path { $projectPath } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $defaultPath -and $ChildPath -eq $projectName } -Verifiable
		Mock Get-Item { @{ FullName = $canonicalProjectPath } } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $projectPath } -Verifiable
		Mock Test-Path { $true } -ModuleName GitWorktreeProjects -ParameterFilter { $Path -eq $canonicalProjectPath } -Verifiable

		{ New-GitWorktreeProject -Project $projectName -Repository $repository } | Should -Throw "Folder '${canonicalProjectPath}' must not yet exist!"

		Should -InvokeVerifiable
	}
}
