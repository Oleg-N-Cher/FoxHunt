@ECHO OFF
IF NOT "%XDev%"=="" GOTO XDev
ECHO Please set system variable XDev=X:\Path\To\XDev
PAUSE
EXIT

:XDev

SET MainMod=FoxHunt
SET CodeAdr=32832
SET DataAdr=50000
SET Options=--reserve-regs-iy --max-allocs-per-node 200000
SET Include=-I ..\Lib\C -I ..\Lib\Obj
SET Target=TAP

%XDev%\ZXDev\Bin\Build.bat %1
