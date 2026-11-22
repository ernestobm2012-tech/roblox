@echo off
REM ============================================================
REM  ACTUALIZAR
REM  Baja de GitHub lo ultimo que ha hecho Claude (git pull).
REM  Si CONECTAR esta abierto, los cambios aparecen solos en Studio.
REM ============================================================
cd /d "%~dp0"
echo.
echo  Bajando lo ultimo que ha hecho Claude...
git fetch origin --prune
if errorlevel 1 goto error
git remote set-head origin -d >nul 2>&1
set RAMA=
for /f "delims=" %%b in ('git for-each-ref --sort^=-committerdate --count^=1 --format^="%%(refname:lstrip=3)" refs/remotes/origin') do set RAMA=%%b
if "%RAMA%"=="" goto error
git checkout -f -B %RAMA% origin/%RAMA%
if errorlevel 1 goto error
echo.
echo  ==========================================================
echo   LISTO! Ya tienes lo ultimo de Claude.
echo   Si CONECTAR esta abierto, ya esta en Roblox Studio.
echo   Para probarlo: para el juego y dale otra vez a Play.
echo  ==========================================================
echo.
pause
exit /b 0

:error
echo.
echo  Algo ha fallado. Haz una foto a esta ventana y ensenasela a Claude.
echo.
pause
exit /b 1
