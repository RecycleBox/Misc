@echo	off
pushd	%~dp0

set	cstfile=%CD%\cst

mkdir	txt 2>nul
mkdir	csd 2>nul
mkdir	csr 2>nul

for	/f "usebackq" %%i in (`dir /b %cstfile%\*.cst`) do call :decode %%i

popd
pause
goto	eof

:decode
echo	%1
set	filename=%1
set	filename=%filename:~0,-4%

cst2csd		%cstfile%\%filename%.cst
copy		%cstfile%\*.csd csd >nul 2>nul
del		/q %cstfile%\*.csd 2>nul

csd2csr		csd\%filename%.csd
copy		csd\*.csr csr >nul 2>nul
del		/q csd\*.csr 2>nul

csr2txt		csr\%filename%.csr
copy		csr\*.txt txt >nul 2>nul
del		/q csr\*.txt 2>nul

goto	eof

:eof