$ErrorActionPreference = 'Stop'

# Switch local machine policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine

git submodule update --init
if (!$?) {
	Write-Error "Failed to update git submodules"
	exit 1
}

# Install chocolatey
if (-not (Get-Command -ErrorAction SilentlyContinue choco)) {
	[System.Net.ServicePointManager]::SecurityProtocol = `
		[System.Net.ServicePointManager]::SecurityProtocol -bor 3072 `
		;
	$chocoInstall = 'https://community.chocolatey.org/install.ps1'
	iex ((New-Object System.Net.WebClient).DownloadString($chocoInstall))
}

# Vim configuration
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.vimrc" -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.gvimrc" -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\_vimrc" -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\_gvimrc" -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.vim" -Recurse -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\vimfiles" -Recurse -Force
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.vimrc" `
	-Target "$PSScriptRoot\vim\.vimrc" | Out-Null
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.gvimrc" `
	-Target "$PSScriptRoot\vim\.gvimrc" | Out-Null
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\_vimrc" `
	-Target "$PSScriptRoot\vim\.vimrc" | Out-Null
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.vim" `
	-Target "$PSScriptRoot\vim" | Out-Null
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\vimfiles" `
	-Target "$PSScriptRoot\vim" | Out-Null


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

# Hg configuration
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.hgrc" -Force
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.hgrc" `
	-Target "$PSScriptRoot\.hgrc"

# Git configuration
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.gitconfig" -Force
Remove-Item -ErrorAction SilentlyContinue -Path "$env:USERPROFILE\.gitconfig-windows" -Force
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.gitconfig" `
	-Target "$PSScriptRoot\.gitconfig"
New-Item -ItemType 'SymbolicLink' `
	-Path "$env:USERPROFILE\.gitconfig-windows" `
	-Target "$PSScriptRoot\.gitconfig-windows"

# Install chocolatey packages
choco install -y packages.config
if (!$?) {
	Write-Error "Failed to install choco packages"
	exit 1
}

# GPG agent startup
$gpgTaskConfig = @{
	TaskName = 'Start GPG Agent';
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

# Cleanup after cmder
if ($env:CMDER_ROOT) {
	Remove-Item -Force -Recurse -Path "$env:CMDER_ROOT\vendor\git-for-windows"
}
if ($env:ChocolateyInstall) {
	& "$env:ChocolateyInstall\bin\RefreshEnv.cmd"
}

# Replace origin
git remote rm origin
git remote add origin git@github.com:mendsley/config
Remove-Item -Force -Path "$env:GIT_INSTALL_ROOT\usr\bin\vim.exe"
