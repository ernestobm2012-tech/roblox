@echo off
REM ============================================================
REM  CONECTAR
REM  Enciende Rojo, que manda el codigo a Roblox Studio.
REM  NO cierres esta ventana mientras juegas.
REM ============================================================
cd /d "%~dp0"
if not exist rojo.exe goto falta
echo.
echo  ==========================================================
echo   Rojo esta ENCENDIDO. NO cierres esta ventana.
echo   Ahora en Roblox Studio: pestana Plugins, boton Rojo, Connect.
echo  ==========================================================
echo.
rojo.exe serve
pause
exit /b 0

:falta
echo.
echo  Falta Rojo. Primero haz doble clic en INSTALAR.bat
echo.
pause
exit /b 1
