
SETLOCAL EnableDelayedExpansion
@echo off
cls
del build\*.o

SET "debug="
SET "cwDWARF="
if "%1" equ "-d" SET "debug=-debug -map=^"C:\Users\admin\Documents\Dolphin Emulator\Maps\RMCP01.map^" -readelf=^"C:\MinGW\bin\readelf.exe^""
if "%1" equ "-d" SET "cwDWARF=-g"


:: Destination (change as necessary)
SET "SOURCE=Pulsar"
SET "RIIVO=C:\Users\admin\Documents\Dolphin Emulator\Load\Riivolution\Pulsar"
SET "ENGINE=C:\Users\janor\Documents\GitHub\Pulsar\KamekInclude"
SET "CREATOR=C:\Users\janor\Documents\GitHub\Pulsar\PulsarPackCreator\Resources"


:: CPP compilation settings
SET CC="C:\Program Files (x86)\Freescale\CW for MPC55xx and MPC56xx 2.10\PowerPC_EABI_Tools\Command_Line_Tools\mwcceppc.exe"
SET CFLAGS=-I- -i "KamekInclude" -i "GameSource" -i "GameSource/MarioKartWii" -i PulsarEngine ^
  -opt all -inline auto -enum int -fp hard -sdata 0 -sdata2 0 -maxerrors 1 -func_align 4 %cwDWARF%
SET DEFINE=

:: CPP Sources
SET CPPFILES=
for /R PulsarEngine %%f in (*.cpp) do SET "CPPFILES=%%f !CPPFILES!"

:: Compile CPP
%CC% %CFLAGS% -c -o "build/kamek.o" "%ENGINE%\kamek.cpp"

SET OBJECTS=
FOR %%H IN (%CPPFILES%) DO (
    ::echo "Compiling %%H..."
    %CC% %CFLAGS% %DEFINE% -c -o "build/%%~nH.o" "%%H"
    SET "OBJECTS=build/%%~nH.o !OBJECTS!"
)

:: Link
echo Linking... %time%
"KamekLinker/Kamek" "build/kamek.o" %OBJECTS% %debug% -dynamic -externals="GameSource/symbols.txt" -versions="GameSource/versions.txt" -output-combined=build\Code.pul

if %ErrorLevel% equ 0 (
    :: xcopy /Y build\*.pul "%RIIVO%\Binaries" >nul
    xcopy /Y build\*.pul "%CREATOR%" >nul
    echo Binaries copied
)

:end
ENDLOCAL