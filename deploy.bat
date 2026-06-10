@echo off
chcp 65001 >nul
color 0A
echo ============================================
echo   Conway - Automatický GitHub deploy
echo ============================================

echo.
echo [1] Ukládám změny...
git add .
git commit -m "Automatický deploy"

echo.
color 0E
echo [2] Odesílám na GitHub...
git push

echo.
color 0B
echo [3] Generuji a nasazuji web...
mkdocs gh-deploy

echo.
color 0A
echo ✅ Hotovo! Web bude dostupný za pár sekund.
pause

