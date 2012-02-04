@echo off
setlocal

	set "ROOT=%~dp0"
	set "HOME=%USERPROFILE%"

	:: vim/gvim configuration
	del %HOME%\_gvimrc
	del %HOME%\_vimrc
	del %HOME%\.gvimrc
	rmdir /s /q %HOME%\.vim
	rmdir /s /q %HOME%\vimfiles
	mklink %HOME%\.vimrc "%ROOT%\vim\.vimrc"
	mklink %HOME%\.gvimrc "%ROOT%\vim\.gvimrc"
	mklink /D %HOME%\.vim "%ROOT%\vim"
	mklink %HOME%\_vimrc "%HOME%\.vimrc"
	mklink /D %HOME%\vimfiles "%HOME%\.vim"

endlocal
