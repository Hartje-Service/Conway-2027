@echo off
chcp 65001 >nul

:menu
cls
echo ============================================
echo   Conway - Správa projektu
echo ============================================
echo.
echo 1) Spustit lokální server
echo 2) Deploy na GitHub
echo 3) Konec
echo.
set /p choice=Vyber akci: 

if "%choice%"=="1" goto serve
if "%choice%"=="2" goto deploy
if "%choice%"=="3" exit
goto menu

:serve
color 0B
echo Přepínám base_url na lokální...
powershell -Command "(Get-Content mkdocs.yml) -replace 'base_url: \"https://hartje-service.github.io/V-robn-manu-l\"', 'base_url: \"\"' | Set-Content mkdocs.yml"
echo Spouštím lokální server...
mkdocs serve
pause


:deploy
color 0A
echo Přepínám base_url na produkční...
powershell -Command "(Get-Content mkdocs.yml) -replace 'base_url: \"\"', 'base_url: \"https://hartje-service.github.io/V-robn-manu-l\"' | Set-Content mkdocs.yml"

echo.
echo Ukládám změny...
git add .
git commit -m "Automatický deploy"

echo.
echo Odesílám na GitHub...
git push

echo.
echo Generuji web...
mkdocs gh-deploy

echo.
color 0A
echo ============================================
echo   ✅ Hotovo! Web bude dostupný za pár sekund.
echo ============================================

echo Otevírám web v prohlížeči...
start https://hartje-service.github.io/V-robn-manu-l

pause
goto menu
