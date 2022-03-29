@echo off
setlocal

	git.exe submodule update --init

	set "ROOT=%~dp0"
	set "HOME=%USERPROFILE%"

	:: vim/gvim configuration
	del %HOME%\.vimrc 1>nul 2>nul
	del %HOME%\.gvimrc 1>nul 2>nul
	del %HOME%\_gvimrc 1>nul 2>nul
	del %HOME%\_vimrc 1>nul 2>nul
	rmdir /s /q %HOME%\.vim 1>nul 2>nul
	rmdir /s /q %HOME%\vimfiles 1>nul 2>nul
	mklink %HOME%\.vimrc "%ROOT%\vim\.vimrc"
	mklink %HOME%\.gvimrc "%ROOT%\vim\.gvimrc"
	mklink /D %HOME%\.vim "%ROOT%\vim"
	mklink %HOME%\_vimrc "%HOME%\.vimrc"
	mklink /D %HOME%\vimfiles "%HOME%\.vim"

	del %HOME%\.ssh\config 1>nul 2>nul
	mkdir %HOME%\.ssh 1>nul 2>nul
	mklink %HOME%\.ssh\config %ROOT%\ssh_config

	:: git configuration
	del %HOME%\.gitconfig
	mklink %HOME%\.gitconfig "%ROOT%\.gitconfig"

	:: hg configuration
	del %HOME%\.hgrc
	mklink %HOME%\.hgrc "%ROOT%\.hgrc"

	:: GPG configuration
	if not exist "%APPDATA%\gnupg" mkdir "%APPDATA%\gnupg"
	echo enable-putty-support> "%APPDATA%\gnupg\gpg-agent.conf"
	echo allow-loopback-pinentry>> "%APPDATA%\gnupg\gpg-agent.conf"
	echo default-cache-ttl 86400>> "%APPDATA%\gnupg\gpg-agent.conf"
	echo default-cache-ttl-ssh 86400>> "%APPDATA%\gnupg\gpg-agent.conf"

	echo use-agent> "%APPDATA%\gnupg\gpg.conf"
	echo pinentry-mode loopback>> "%APPDATA%\gnupg\gpg.conf"

	:: SSH Agent configuration
	if not exist "%HOME%\.ssh" mkdir "%HOME%\.ssh
	setx SSH_AUTH_SOCK "%HOME%\.ssh\auth_sock"

endlocal
