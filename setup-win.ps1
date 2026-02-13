param(
	[switch]$AdminOnly
)

$ErrorActionPreference = 'Stop'

$goupVersion = "1.7.0"
$goVersion = "1.25.5"
$ompTheme = "multiverse-neon"

# Check if we're running as administrator
function Test-Administrator {
	$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
	$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Run administrator tasks first
if (-not (Test-Administrator)) {
	Write-Host "Elevating to run admin commands..."
	$adminScript = "-File $($PSCommandPath) -AdminOnly"
	Start-Process -Wait -Verb RunAs powershell.exe -ArgumentList $adminScript
}

if ($AdminOnly) {
	# Switch local machine policy
	Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

	# Enable developer mode
	$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
	if (-not (Test-Path -Path $devModePath)) {
		New-Item -Path $devModePath -Force | Out-Null
	}
	Set-ItemProperty `
		-Path $devModePath `
		-Name AllowDevelopmentWithoutDevLicense `
		-Value 1 `
		-Type DWord `
		;

	# Configure neovim
	if (Test-Path -Path "$env:LOCALAPPDATA\nvim") {
		Remove-Item -Force -Recurse -Path "$env:LOCALAPPDATA\nvim"
	}
	New-Item -ItemType 'SymbolicLink' `
		-Path "$env:LOCALAPPDATA\nvim" `
		-Target "$PSScriptRoot\nvim" `
		| Out-Null

	# Git configuration
	Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.gitconfig" -Force
	Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.gitconfig-windows" -Force
	New-Item -ItemType 'SymbolicLink' `
		-Path "$env:USERPROFILE\.gitconfig" `
		-Target "$PSScriptRoot\.gitconfig" `
		| Out-Null
	New-Item -ItemType 'SymbolicLink' `
		-Path "$env:USERPROFILE\.gitconfig-windows" `
		-Target "$PSScriptRoot\.gitconfig-windows" `
		| Out-Null

	# SSH configuration
	New-Item -Path "$env:USERPROFILE\.ssh" -ItemType 'Directory' -Force | Out-Null
	Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.ssh\config" -Force
	New-Item -ItemType 'SymbolicLink' `
		-Path "$env:USERPROFILE\.ssh\config" `
		-Target "$PSScriptRoot\ssh_config" | Out-Null

	# GPG configuration
	New-Item -ItemType 'Directory' -Path "$env:APPDATA\gnupg" -Force | Out-Null
	$gpgAgentConf = @"
enable-win32-openssh-support
allow-loopback-pinentry
default-cache-ttl 86400
default-cache-ttl-ssh 86400
"@
	Set-Content `
		-Path "$env:APPDATA\gnupg\gpg-agent.conf" `
		-Value $gpgAgentConf `
		-Encoding utf8 `
		-NoNewLine `
		;
	$gpgConf = @"
use-agent
pinentry-mode loopback
"@
	Set-Content `
		-Path "$env:APPDATA\gnupg\gpg.conf" `
		-Value $gpgConf `
		-Encoding utf8 `
		-NoNewLine `
		;

	# GPG agent startup
	$gpgTaskConfig = @{
		TaskName = 'Start GPG Agent'
	Action = New-ScheduledTaskAction -Execute (Get-Command gpg-connect-agent).Source -Argument '/bye';
		Trigger = New-ScheduledTaskTrigger -AtLogOn;
		Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited;
	}
	$existingTask =  Get-ScheduledTask -TaskName $gpgTaskConfig.TaskName -ErrorAction SilentlyContinue
	if ($null -eq $existingTask) {
		Register-ScheduledTask -TaskName $gpgTaskConfig.TaskName `
			-Action $gpgTaskConfig.Action `
			-Trigger $gpgTaskConfig.Trigger `
			-Principal $gpgTaskConfig.Principal | Out-Null
		Write-Host "Created gpg-connect-agent task"
	} else {
		Set-ScheduledTask -TaskName $gpgTaskConfig.TaskName `
			-Action $gpgTaskConfig.Action `
			-Trigger $gpgTaskConfig.Trigger `
			-Principal $gpgTaskConfig.Principal | Out-Null

		Write-Host "Updated gpg-connect-agent task"
	}

	exit 0
}

[System.Environment]::SetEnvironmentVariable('EDITOR', 'nvim', [System.EnvironmentVariableTarget]::User)

# Install scoop
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
	Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

$packagesJson = Get-Content -Path "$PSScriptRoot\packages.json" -Raw | ConvertFrom-Json
foreach ($bucket in $packagesJson.buckets) {
	scoop bucket add $bucket
}

foreach ($package in $packagesJson.packages) {
	$name = if ($package -is [string]) { $package } else { $package.name }
	scoop install $name
	if (!$?) {
		Write-Warning "Failed to install $name"
	}
}

foreach ($package in $packagesJson.admin_packages) {
	gsudo scoop install --global $package
}

# GPG configuration
New-Item -Path "$env:USERPROFILE\.gnupg" -ItemType Directory -Force | Out-Null

# Setup goup (Go version manager)
if (-not (Get-Command goup -ErrorAction SilentlyContinue)) {
	Write-Host "Installing goup..."
	$goupUrl = "https://github.com/zekroTJA/goup/releases/download/v$goupVersion/goup-v1.7.0-x86_64-pc-windows-msvc.exe"
	$goupDir = "$env:USERPROFILE\.local\bin"
	$groupPath = "$goupDir\goup.exe"

	New-Item -ItemType Directory -Path $goupDir -Force | Out-Null
	Invoke-WebRequest -Uri $goupUrl -OutFile $groupPath

	# add to PATH
	$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
	if ($currentPath -notlike "*$goupDir*") {
		[Environment]::SetEnvironmentVariable("PATH", "$currentPath;$goupDir", "User")
	}
	$env:PATH += ";$goupDir"

	# add go paths
	$env:GOROOT = "$env:USERPROFILE\.local\goup\current\go"
	[Environment]::SetEnvironmentVariable("GOROOT", $env:GOROOT, "User")

	$goupGoPath = "$($env:GOROOT)\bin"
	$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
	if ($currentPath -notlike "*$goupGoPath*") {
		[Environment]::SetEnvironmentVariable("PATH", "$currentPath;$goupGoPath", "User")
	}
	$env:PATH += ";goupGoPath"
}

# Install go
goup use $goVersion
if (!$?) {
	Write-Error "Failed to install go $goVersion"
}

# Setup windows terminal to use pwsh
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path -Path $wtSettingsPath) {

	$settings = Get-Content -Path $wtSettingsPath -Raw -Encoding UTF8 `
		| ConvertFrom-Json `
		;

	$settings.defaultProfile = "{574e775e-4f2a-5b96-ac1e-a2962a402336}"

	$profiles = [ordered]@{
		defaults = [ordered]@{
			cursorShape = "bar"
			"experimental.retroTerminalEffect" = $false
			font = @{
				face = "MesloLGM Nerd Font"
				size = 10
			}
		}
		list = $settings.profiles.list
	}

	Add-Member `
		-Force `
		-InputObject $settings`
		-MemberType NoteProperty `
		-Name "profiles" `
		-Value $profiles `
		;

	$settings `
		| ConvertTo-Json -Depth 10 `
		| Set-Content -Path $wtSettingsPath -Encoding UTF8 `
		;
}

# Setup oh-my-posh/posh-git
pwsh -Command 'oh-my-posh font install meslo'

pwsh -Command 'Install-Module posh-git -Scope CurrentUser -Force -Confirm:$false -AllowClobber'
pwsh -Command 'Install-Module PSFzf -Scope CurrentUser -Force -Confirm:$false -AllowClobber'

$poshGitCommand = "Import-Module posh-git"
$ompCommand = "oh-my-posh init pwsh --config `"`$env:POSH_THEMES_PATH\multiverse-neon.omp.json`" | Invoke-Expression"

$profilePath =  pwsh -Command 'Write-Host $PROFILE.CurrentUserCurrentHost'
$profileDir = Split-Path -Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
	New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

$profileContent = @("")
if (Test-Path -Path $profilePath) {
	$profileContent = Get-Content -Path $profilePath -Raw `
		| Where-Object { $_ -notmatch 'oh-my-posh init pwsh' } `
		| Where-Object { $_ -notmatch 'posh-git' } `
		| Where-Object { $_ -notmatch 'PSFzf' } `
		| Where-Object { $_ -notmatch 'Set-PsFzfOption' } `
		| Where-Object { $_ -notmatch '\beza\b' } `
		| Where-Object { $_ -notmatch '\bbat\b' } `
		;
}

$profileContent += "$ompCommand`n"
$profileContent += "$poshGitCommand`n"

$fzfEzaBatBlock = @"

# fzf integration
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'

# eza aliases
Remove-Alias ls -Force -ErrorAction SilentlyContinue
Set-Alias -Name ls -Value eza
function ll { eza -l @args }
function la { eza -la @args }
function tree { eza --tree @args }

# bat alias
Remove-Alias cat -Force -ErrorAction SilentlyContinue
function cat { bat --plain @args }
"@
$profileContent += "$fzfEzaBatBlock`n"

$profileContent | Set-Content -Path $profilePath -Encoding UTF8

# install corepack
npm install -g corepack
"y" | corepack enable

# Go tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

# Install claude
$bashCommand = Get-Command 'bash'
[System.Environment]::SetEnvironmentVariable('CLAUDE_CODE_GIT_BASH_PATH', $bashCommand.Source, 'User')
$env:SHELL = $bashCommand.Source
$env:CLAUDE_CODE_GIT_BASH_PATH = $bashCommand.Source
irm https://claude.ai/install.ps1 | iex

# Claude config
claude mcp add --transport http clickup https://mcp.clickup.com/mcp
claude mcp add --transport http github https://api.githubcopilot.com/mcp

# Replace origin
git remote rm origin
git remote add origin git@github.com:mendsley/config

$gitVimPath = "$env:GIT_INSTALL_ROOT\usr\bin\vim.exe"
if (Test-Path -Path $gitVimPath) {
	Remove-Item -Force -Path $gitVimPath
}

$gitGpgPath = "$env:GIT_INSTALL_ROOT\usr\bin\gpg.exe"
if (Test-Path -Path $gitGpgPath) {
	Remove-Item -Force -Path $gitGpgPath
}
