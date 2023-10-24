del ..\Bin\Emu\sdcard\lemmings.bas
..\Bin\AgonBasic.exe -var -rem Lemmings.bas ..\Bin\Emu\sdcard\lemmings.bas
if ERRORLEVEL 1 goto doexit

if exist ..\Bin\Emu\sdcard\lemmings.bas (
copy autoexec.txt ..\Bin\Emu\sdcard\autoexec.txt
cd ..\bin\Emu
fab-agon-emulator.exe --scale 1024
rem fab-agon-emulator.exe -f
cd ..\..\TestProgram
) else (
	echo	*****************************************************************
	echo	Build Error.
	echo	*****************************************************************
)
:doexit

