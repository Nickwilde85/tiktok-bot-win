@echo off
chcp 65001 >nul
title Установка FFmpeg

echo ========================================
echo   Установка FFmpeg
echo ========================================
echo.

REM Проверка, установлен ли уже FFmpeg
where ffmpeg >nul 2>&1
if not errorlevel 1 (
    echo [OK] FFmpeg уже установлен!
    ffmpeg -version | findstr "ffmpeg version"
    echo.
    pause
    exit /b 0
)

echo FFmpeg не найден. Выберите способ установки:
echo.
echo [1] Автоматическая установка через winget (Windows 11)
echo [2] Автоматическая установка через Chocolatey
echo [3] Показать инструкцию для ручной установки
echo [4] Скачать портативную версию в папку проекта
echo.
set /p choice="Выберите вариант (1-4): "

if "%choice%"=="1" goto :winget_install
if "%choice%"=="2" goto :choco_install
if "%choice%"=="3" goto :manual_instructions
if "%choice%"=="4" goto :portable_install
echo Неверный выбор!
pause
exit /b 1

:winget_install
echo.
echo [INFO] Установка через winget...
where winget >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] winget не найден!
    echo winget доступен только на Windows 10 (версия 1809+) и Windows 11
    echo.
    goto :manual_instructions
)

winget install --id Gyan.FFmpeg -e --silent
if errorlevel 1 (
    echo [ОШИБКА] Не удалось установить через winget
    goto :manual_instructions
)

echo [OK] FFmpeg установлен!
echo Перезапустите командную строку для применения изменений
pause
exit /b 0

:choco_install
echo.
echo [INFO] Установка через Chocolatey...
where choco >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Chocolatey не установлен!
    echo.
    echo Установите Chocolatey:
    echo 1. Откройте PowerShell от имени администратора
    echo 2. Выполните:
    echo    Set-ExecutionPolicy Bypass -Scope Process -Force;
    echo    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
    echo    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    echo.
    echo Или посетите: https://chocolatey.org/install
    pause
    exit /b 1
)

choco install ffmpeg -y
if errorlevel 1 (
    echo [ОШИБКА] Не удалось установить через Chocolatey
    pause
    exit /b 1
)

echo [OK] FFmpeg установлен!
echo Перезапустите командную строку для применения изменений
pause
exit /b 0

:portable_install
echo.
echo [INFO] Скачивание портативной версии FFmpeg...
echo.

set "FFMPEG_DIR=%~dp0ffmpeg"
set "FFMPEG_BIN=%FFMPEG_DIR%\bin"

if exist "%FFMPEG_BIN%\ffmpeg.exe" (
    echo [OK] FFmpeg уже установлен в папке проекта!
    goto :add_to_path_local
)

echo Скачивание FFmpeg...
echo Это может занять несколько минут...
echo.

REM Используем PowerShell для скачивания
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip' -OutFile '%TEMP%\ffmpeg.zip'}"

if errorlevel 1 (
    echo [ОШИБКА] Не удалось скачать FFmpeg
    echo Попробуйте другой способ установки
    pause
    exit /b 1
)

echo Распаковка...
powershell -Command "Expand-Archive -Path '%TEMP%\ffmpeg.zip' -DestinationPath '%TEMP%\ffmpeg_extract' -Force"

REM Найти папку с ffmpeg и скопировать bin
for /d %%i in ("%TEMP%\ffmpeg_extract\ffmpeg-*") do (
    if exist "%%i\bin" (
        mkdir "%FFMPEG_DIR%" 2>nul
        xcopy "%%i\bin" "%FFMPEG_BIN%\" /E /I /Y >nul
    )
)

REM Очистка
del "%TEMP%\ffmpeg.zip" 2>nul
rmdir /s /q "%TEMP%\ffmpeg_extract" 2>nul

if exist "%FFMPEG_BIN%\ffmpeg.exe" (
    echo [OK] FFmpeg установлен в: %FFMPEG_BIN%
    goto :add_to_path_local
) else (
    echo [ОШИБКА] Не удалось установить FFmpeg
    pause
    exit /b 1
)

:add_to_path_local
echo.
echo Добавление FFmpeg в PATH для текущей сессии...
set "PATH=%FFMPEG_BIN%;%PATH%"

echo.
echo ========================================
echo   FFmpeg установлен!
echo ========================================
echo.
echo Расположение: %FFMPEG_BIN%
echo.
echo ВАЖНО: Для постоянного использования добавьте в системный PATH:
echo %FFMPEG_BIN%
echo.
echo Или используйте start_bot.bat (он автоматически добавит FFmpeg в PATH)
echo.
pause
exit /b 0

:manual_instructions
echo.
echo ========================================
echo   Ручная установка FFmpeg
echo ========================================
echo.
echo Шаг 1: Скачайте FFmpeg
echo   https://github.com/BtbN/FFmpeg-Builds/releases
echo   Выберите: ffmpeg-master-latest-win64-gpl.zip
echo.
echo Шаг 2: Распакуйте архив
echo   Например в: C:\ffmpeg
echo.
echo Шаг 3: Добавьте в PATH
echo   1. Win + R → sysdm.cpl
echo   2. Дополнительно → Переменные среды
echo   3. Системные переменные → Path → Изменить
echo   4. Создать → C:\ffmpeg\bin
echo   5. ОК → ОК → ОК
echo.
echo Шаг 4: Перезапустите командную строку
echo.
echo Проверка установки:
echo   ffmpeg -version
echo.
pause
exit /b 0
