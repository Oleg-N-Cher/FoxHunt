@ECHO OFF
IF NOT "%XDev%"=="" GOTO XDev
ECHO Please set system variable XDev=X:\Path\To\XDev
PAUSE
EXIT

:XDev

SET MainMod=FoxHunt
SET Options=--reserve-regs-iy
SET Include=-I ..\Lib\C -I ..\Lib\Obj

%XDev%\ZXDev\Bin\Compile.bat %1
