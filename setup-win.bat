@echo off
setlocal

powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; ./setup-win.ps1"

	:: Cleanup Cmder
	if defined CMDER_ROOT (
		rmdir /s /q "%CMDER_ROOT%\vendor\git-for-windows"
	)

	if defined ChocolateyInstall (
		call "%ChocolateyInstall%\bin\RefreshEnv.cmd"
	)

	git remote rm origin
	git remote add origin git@github.com:mendsley/config
	del "%GIT_INSTALL_ROOT%\usr\bin\vim.exe"

endlocal
