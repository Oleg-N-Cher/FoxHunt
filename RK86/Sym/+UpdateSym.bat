@IF "%XDev%"=="" GOTO noXDev

@FOR %%i IN (*.sym) DO COPY /B /Y %XDev%\K580Dev\Lib\Sym\%%i
@EXIT

:noXDev

@ECHO Please set system variable XDev=X:\Path\To\XDev
@PAUSE
