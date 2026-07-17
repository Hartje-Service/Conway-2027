@echo off
chcp 1250 >nul
setlocal enabledelayedexpansion

:: ============================================
::  Konfigurace (upravit podle potřeby)
:: ============================================
set "ROOT=Z:\PRODUCTION\Výrobní manuál\Projekty"
set "TOKEN_FILE=Z:\PRODUCTION\Výrobní manuál\github_token.txt"
set "GITHUB_USER=hartje-service"

:: ============================================
::  Kontrola základních cest a tokenu
:: ============================================
if not exist "%ROOT%" (
  echo Chyba: Cesta %ROOT% neexistuje.
  pause
  exit /b
)

if not exist "%TOKEN_FILE%" (
  echo Chyba: Soubor s GitHub tokenem nebyl nalezen: %TOKEN_FILE%
  pause
  exit /b
)

for /f "usebackq delims=" %%T in ("%TOKEN_FILE%") do set "GITHUB_TOKEN=%%T"

if "%GITHUB_TOKEN%"=="" (
  echo Chyba: GitHub token je prazdny.
  pause
  exit /b
)

:: ============================================
::  Funkce: vypsat projekty a vybrat
:: ============================================
:menu
cls
echo ============================================
echo        Sprava projektu - Conway / Hartje
echo ============================================
echo.
set count=0
for /f "delims=" %%D in ('dir "%ROOT%" /b /ad 2^>nul') do (
  set "folder=%%D"
  rem vynechat systemove slozky
  if /I not "!folder!"=="_SABLONY" (
    if /I not "!folder!"=="docs" (
      set /a count+=1
      set "proj[!count!]=!folder!"
    )
  )
)

if %count%==0 (
  echo Zadne projekty nenalezeny v %ROOT%.
) else (
  echo Existujici projekty:
  for /l %%i in (1,1,%count%) do (
    echo %%i^) !proj[%%i]!
  )
)
set /a new_option=count+1
echo %new_option%^) + Vytvorit novy projekt
echo.
set /p choice=Zadej cislo (Enter pro zrusit): 

if "%choice%"=="" (
  echo Ukonceno.
  pause
  exit /b
)

rem pokud uzivatel zada cislo v rozsahu existujicich projektu
for /l %%i in (1,1,%count%) do (
  if "%choice%"=="%%i" (
    set "project=!proj[%%i]!"
    goto :setup_content
  )
)

if "%choice%"=="%new_option%" goto :newproject

echo Neplatna volba.
pause
goto :menu

:: ============================================
::  Vytvoreni noveho projektu
:: ============================================
:newproject
cls
echo ============================================
echo        Vytvoreni noveho projektu
echo ============================================
echo.
set /p project=Zadej nazev noveho projektu (bez diakritiky): 
if "%project%"=="" (
  echo Nebyl zadan nazev projektu.
  pause
  goto :menu
)
rem vytvorit slozku projektu
mkdir "%ROOT%\%project%" >nul 2>&1
echo Projekt '%project%' vytvoren.
goto :setup_content

:: ============================================
::  Spolecne: doplnit obsah projektu
:: ============================================
:setup_content
echo.
echo Pracuji na projektu: %project%
set "PROJECT_DIR=%ROOT%\%project%"
pushd "%PROJECT_DIR%" >nul 2>&1

:: vytvorit strukturu slozek
mkdir "docs" >nul 2>&1
mkdir "docs\images" >nul 2>&1
mkdir "docs\modely" >nul 2>&1
mkdir "docs\modules" >nul 2>&1
mkdir "docs\modules\.Template" >nul 2>&1
mkdir "docs\modules\.Template\images" >nul 2>&1
mkdir "docs\obecne" >nul 2>&1
mkdir "docs\prilohy" >nul 2>&1
mkdir "docs\styles" >nul 2>&1

:: ============================================
::  index.md (UTF-8) - pouze PowerShell bloky pouzivaji UTF-8
:: ============================================
powershell -NoLogo -NoProfile -Command ^
 "Set-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '# Manuál Hartje' -Encoding UTF8"

powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value 'Tento manuál slouží jako oficiální výrobní dokumentace pro značky Hartje e-factory.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value 'Obsahuje postupy montáže, kontrolní kroky a specifické informace pro jednotlivé operace.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '---' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '## Účel dokumentu' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value 'Zajistit jednotný výrobní proces, kontrolu kvality a správnou montáž všech kol.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '---' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '> Poznámka: Tento manuál je určen výhradně pro interní použití ve výrobě.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '> Datum vytvoření:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%PROJECT_DIR%\docs\index.md' -Value '> Autor: David Kubíček' -Encoding UTF8"

:: ============================================
::  extra.css (CMD-safe echo)
:: ============================================
set "CSSFILE=%PROJECT_DIR%\docs\styles\extra.css"

> "%CSSFILE%" echo .custom-header {
>> "%CSSFILE%" echo   width: 100%;
>> "%CSSFILE%" echo   background-color: #0b4ea2;
>> "%CSSFILE%" echo   padding: 8px 20px;
>> "%CSSFILE%" echo   display: flex;
>> "%CSSFILE%" echo   align-items: center;
>> "%CSSFILE%" echo   justify-content: flex-start;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo .custom-header img {
>> "%CSSFILE%" echo   height: 45px;
>> "%CSSFILE%" echo   object-fit: contain;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo /* Fixní vodoznak Conway */
>> "%CSSFILE%" echo .md-content::before {
>> "%CSSFILE%" echo     content: "";
>> "%CSSFILE%" echo     position: fixed;
>> "%CSSFILE%" echo     top: 50%%;
>> "%CSSFILE%" echo     left: 50%%;
>> "%CSSFILE%" echo     width: 800px;
>> "%CSSFILE%" echo     height: 800px;
>> "%CSSFILE%" echo     background-image: url("../images/vodoznak-conway.png");
>> "%CSSFILE%" echo     background-repeat: no-repeat;
>> "%CSSFILE%" echo     background-size: contain;
>> "%CSSFILE%" echo     background-position: center;
>> "%CSSFILE%" echo     opacity: 0.35;
>> "%CSSFILE%" echo     transform: translate(-50%%, -50%%);
>> "%CSSFILE%" echo     z-index: 0;
>> "%CSSFILE%" echo     pointer-events: none;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo .md-content img {
>> "%CSSFILE%" echo     display: block;
>> "%CSSFILE%" echo     margin-left: auto;
>> "%CSSFILE%" echo     margin-right: auto;
>> "%CSSFILE%" echo     margin-bottom: 25px;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo .row {
>> "%CSSFILE%" echo     display: flex;
>> "%CSSFILE%" echo     justify-content: center;
>> "%CSSFILE%" echo     gap: 20px;
>> "%CSSFILE%" echo     margin: 20px 0;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo .row img {
>> "%CSSFILE%" echo     display: inline-block;
>> "%CSSFILE%" echo     margin: 0;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo table {
>> "%CSSFILE%" echo   font-size: 0.9rem;
>> "%CSSFILE%" echo   border-collapse: collapse;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo th, td {
>> "%CSSFILE%" echo   border-bottom: 1px solid #ddd;
>> "%CSSFILE%" echo   padding: 6px 12px;
>> "%CSSFILE%" echo }
>> "%CSSFILE%" echo th {
>> "%CSSFILE%" echo   background-color: #f5f5f5;
>> "%CSSFILE%" echo   font-weight: 600;
>> "%CSSFILE%" echo }

:: ============================================
::  .Template modul (modul.md) a placeholder PNG
:: ============================================
set "TEMPLATE_DIR=%PROJECT_DIR%\docs\modules\.Template"
set "TEMPLATE_MD=%TEMPLATE_DIR%\modul.md"
set "TEMPLATE_IMG=%TEMPLATE_DIR%\images\main.png"

powershell -NoLogo -NoProfile -Command ^
 "Set-Content -LiteralPath '%TEMPLATE_MD%' -Value '## Obrázek' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '<img src=\"{{ base_url }}/modules/jmeno-modulu/images/main.png\" width=\"70%\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '## Text' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '<div style=\"text-align: justify;\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value 'Stručný technický popis modulu.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value 'Co to je, k čemu slouží, jaká je jeho funkce v rámci kola QiO.' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '</div>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '## 2 Obrázky vedle sebe' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '<div class=\"row\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '  <img src=\"{{ base_url }}/modules/jmeno-modulu/images/main.png\" width=\"45%\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '  <img src=\"{{ base_url }}/modules/jmeno-modulu/images/main.png\" width=\"45%\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '</div>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '## text vedle obrázku' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '<div style=\"display: flex; align-items: center; gap: 40px;\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '  <img src=\"{{ base_url }}/modules/jmeno-modulu/images/main.png\" width=\"70%\">' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '  <div>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '    <h3>Použitý materiál</h3>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '     → <br>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '     → <br>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '     → <br>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '  </div>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '</div>' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '## Tabulka' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| Kód komponentu | Název | Poznámka |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '|----------------|--------|----------|' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 35000-EB1320003V | Purion 200 | Displej |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 40000-HDM3120F | Přední brzda | Shimano MT312 |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 40000-HDM3120R | Zadní brzda | Shimano MT312 |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 50000-SLC60018L170 | Ručka řazení | Shimano SL-C6000 |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 58000-318228M | Rucky | Herrmans DD32 |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 59000-000660 | Řidítka | 720 mm, hliník |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 60000-000860 | Představec | 90 mm, hliník |' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%TEMPLATE_MD%' -Value '| 61000-03209170 | Zvonek | Standardní |' -Encoding UTF8"

:: Vytvoreni placeholder PNG (Windows PowerShell System.Drawing)
powershell -NoLogo -NoProfile -Command ^
 "Add-Type -AssemblyName System.Drawing; $imgPath = '%TEMPLATE_IMG%'; $bmp = New-Object System.Drawing.Bitmap 800,600; $g = [System.Drawing.Graphics]::FromImage($bmp); $g.Clear([System.Drawing.Color]::FromArgb(240,240,240)); $font = New-Object System.Drawing.Font('Arial',36); $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120,120,120)); $g.DrawString('placeholder', $font, $brush, 20, 260); $bmp.Save($imgPath, [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $bmp.Dispose();"

:: ============================================
::  mkdocs.yml (UTF-8)
:: ============================================
set "MKDOCS=%PROJECT_DIR%\mkdocs.yml"

powershell -NoLogo -NoProfile -Command ^
 "Set-Content -LiteralPath '%MKDOCS%' -Value 'site_name: Značka a rok výroby' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'site_description: Výrobní manuál pro modely' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'site_author: Hartje Production' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'docs_dir: docs' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'theme:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  name: material' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  language: cs' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  palette:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '    primary: ''#0b4ea2''' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '    accent: ''#009fe3''' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  custom_dir: overrides' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'extra_css:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - styles/extra.css' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'plugins:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - search' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - include-markdown:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      preserve_includer_indent: false' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - macros' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'extra:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  base_url: ''''' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'markdown_extensions:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - md_in_html' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - tables' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - admonition' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value 'nav:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - Obecné:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      - Specifikace: obecne/specifikace.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      - Bezpečnost: obecne/bezpecnost.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      - Nástroje: obecne/nastroje.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - Modely:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      - Šablona:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '          - Přehled: modely/Sablona/Přehled.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '          - Montáž: modely/Sablona/Montáž.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '          - Kusovníky: modely/Sablona/Kusovníky.md' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '  - Přílohy:' -Encoding UTF8"
powershell -Command ^
 "Add-Content -LiteralPath '%MKDOCS%' -Value '      - Tabulka momentů: prilohy/tabulka-momentu.md' -Encoding UTF8"

:: ============================================
::  GitHub repo: vytvorit pokud neexistuje, pak git init/push a aktivovat Pages po pushi
:: ============================================
echo Overuji existenci repozitare %project%...
powershell -NoLogo -NoProfile -Command ^
 "$ErrorActionPreference='SilentlyContinue';" ^
 "$uri = 'https://api.github.com/repos/%GITHUB_USER%/%project%';" ^
 "try { $repo = Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization='token %GITHUB_TOKEN%'; Accept='application/vnd.github+json'} } catch { $repo = $null };" ^
 "if (-not $repo) { Write-Host 'Repo neexistuje, vytvarim...'; $body = @{name='%project%'; private=$false} | ConvertTo-Json; Invoke-RestMethod -Method Post -Uri 'https://api.github.com/user/repos' -Headers @{Authorization='token %GITHUB_TOKEN%'; Accept='application/vnd.github+json'} -Body $body -ContentType 'application/json'; Start-Sleep -Seconds 3; Write-Host 'Repozitar byl vytvoren.' } else { Write-Host 'Repozitar jiz existuje.' }"

:: ============================================
::  GIT: init, commit, push
:: ============================================
cd "%PROJECT_DIR%"

git config --global --add safe.directory "%PROJECT_DIR%" >nul 2>&1

if not exist ".git" (
  git init >nul
)

git add . >nul 2>&1
git diff --cached --quiet 2>nul || git commit -m "Initial commit" >nul 2>&1

git branch -M main >nul 2>&1

git remote remove origin >nul 2>&1
git remote add origin https://%GITHUB_USER%:%GITHUB_TOKEN%@github.com/%GITHUB_USER%/%project%.git

git push -u origin main

:: pockej, aby GitHub zaregistroval vetvici
timeout /t 30 >nul

:: pokud Pages nejsou aktivni, proveď prázdný commit jako trigger
powershell -NoLogo -NoProfile -Command ^
 "try { $pages = Invoke-RestMethod -Method Get -Uri 'https://api.github.com/repos/%GITHUB_USER%/%project%/pages' -Headers @{Authorization='token %GITHUB_TOKEN%'; Accept='application/vnd.github+json'}; } catch { $pages = $null } ; if (-not $pages) { Write-Host 'Pages nejsou aktivni, provedu prázdný commit jako trigger...'; git commit --allow-empty -m 'Trigger Pages build' > $null 2>&1; git push > $null 2>&1 }"

:: aktivace Pages (po pushi)
echo Aktivace GitHub Pages...
powershell -NoLogo -NoProfile -Command ^
 "$body=@{source=@{branch='main';path='/'}}; $json=ConvertTo-Json $body; Invoke-RestMethod -Method Post -Uri 'https://api.github.com/repos/%GITHUB_USER%/%project%/pages' -Headers @{Authorization='token %GITHUB_TOKEN%'; Accept='application/vnd.github+json'} -Body $json -ContentType 'application/json'"

:: ============================================
::  QR kod
:: ============================================
set "WEB_URL=https://%GITHUB_USER%.github.io/%project%"
set "QR_URL=https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=%WEB_URL%"

curl -s "%QR_URL%" -o "%PROJECT_DIR%\docs\images\qr-%project%.png"

popd

echo.
echo ============================================
echo HOTOVO! Projekt: %project%
echo Web: %WEB_URL%
echo ============================================
pause
exit /b
