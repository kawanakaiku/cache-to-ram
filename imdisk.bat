@echo off

::run as admin
(Net session >nul 2>&1)&&(cd /d "%~dp0")||(PowerShell start """%~0""" -verb RunAs & Exit /B)

CD /D "%~dp0"

::make temp dirs for temp, Downloads
mkdir %USERPROFILE%\Documents\imdisk\Temp\System %USERPROFILE%\Documents\imdisk\Temp\User %USERPROFILE%\Documents\imdisk\Downloads
rd /s /q "%USERPROFILE%\Downloads"
mkdir "R:\Temp\System" "R:\Temp\User" "R:\Downloads"
mklink /J "%USERPROFILE%\Downloads" "R:\Downloads"


::change temp variables
reg import temp.reg

::HKEY_LOCAL_MACHINE\SOFTWARE\ImDisk
::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ImDiskRD

::make links

setlocal enabledelayedexpansion

set "imdisk=%USERPROFILE%\Documents\imdisk\Temp\"
set "tempdir=R:\Temp\"
set "CSV_file=imdisk.csv"

set Array_Index=0
FOR /F "delims=" %%I IN (%CSV_file%) DO (
    SET "Arr[!Array_Index!]=%%I"
    SET /a Array_Index=!Array_Index!+1
)

for /D %%i in (%LocalAppData%\Mozilla\Firefox\Profiles\*.default-release) do (
    echo "%%i"
    set "Arr[!Array_Index!]=%%i\cache2"
    SET /a Array_Index=!Array_Index!+1
    set "Arr[!Array_Index!]=%%i\startupCache"
    SET /a Array_Index=!Array_Index!+1
)

set I=0
:LOOP
call set Flag=%%Arr[%I%]%%
set /a I=%I% + 1

if not defined Flag ( goto END )

SET Z=&& FOR %%A IN ("%Flag%") DO SET Z=%%~aA
IF "%Z:~8,1%" == "l" (
   echo "already a junction %Flag%"
   goto LOOP
)

if not ["%Flag%"] == [""] (
        echo "processing %Flag%"
	set "tempdir2=%tempdir%%Flag::=%"
	set "imdisk2=%imdisk%%Flag::=%"

        mkdir "%Flag%" > NUL 2>&1
        rd /s /q "%Flag%"
        if not exist "!tempdir2!" mkdir "!tempdir2!"
        if not exist "!imdisk2!" mkdir "!imdisk2!"
        mklink /J "%Flag%" "!tempdir2!"

	goto LOOP
)
endlocal

:END
pause
