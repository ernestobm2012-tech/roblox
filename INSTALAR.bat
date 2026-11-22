@echo off
REM ============================================================
REM  INSTALAR (solo se hace UNA vez)
REM  Descarga Rojo y pone su plugin en Roblox Studio.
REM ============================================================
cd /d "%~dp0"
set VERSION=7.7.1
echo.
echo  Descargando Rojo %VERSION%... (espera un momento)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v%VERSION%/rojo-%VERSION%-windows-x86_64.zip' -OutFile 'rojo.zip'; Expand-Archive -Path 'rojo.zip' -DestinationPath '.' -Force; Remove-Item 'rojo.zip'"
if not exist rojo.exe goto error
echo  Instalando el plugin de Rojo en Roblox Studio...
if not exist "%LOCALAPPDATA%\Roblox\Plugins" mkdir "%LOCALAPPDATA%\Roblox\Plugins"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/rojo-rbx/rojo/releases/download/v%VERSION%/Rojo.rbxm' -OutFile (Join-Path $env:LOCALAPPDATA 'Roblox\Plugins\Rojo.rbxm')"
if not exist "%LOCALAPPDATA%\Roblox\Plugins\Rojo.rbxm" goto error
echo.
echo  ==========================================================
echo   LISTO! Si Roblox Studio estaba abierto, cierralo y abrelo.
echo  ==========================================================
echo.
pause
exit /b 0

:error
echo.
echo  Algo ha fallado. Haz una foto a esta ventana y ensenasela a Claude.
echo  (Comprueba que tienes internet y que Roblox Studio esta instalado.)
echo.
pause
exit /b 1
