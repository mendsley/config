@echo off
setlocal

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

endlocal
