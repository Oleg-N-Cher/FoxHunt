@ECHO OFF
IF NOT "%XDev%"=="" GOTO XDev
ECHO Please set system variable XDev=X:\Path\To\XDev
PAUSE
EXIT

:XDev

SET MainMod=FoxHunt
::SET FileExt=rka
%XDev%/K580Dev/Bin/Build.bat %1
