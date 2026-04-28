@echo off
chcp 65001 >nul
title Установка TikTok Video Downloader Bot

echo ========================================
echo   Установка бота
echo ========================================
echo.

REM Проверка Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ОШИБКА] Python не найден!
    echo Установите Python 3.9+ с https://www.python.org/downloads/
    echo Не забудьте отметить "Add Python to PATH"
    pause
    exit /b 1
)

echo [1/4] Создание виртуального окружения...
python -m venv venv
if errorlevel 1 (
    echo [ОШИБКА] Не удалось создать виртуальное окружение
    pause
    exit /b 1
)

echo [2/4] Активация виртуального окружения...
call venv\Scripts\activate.bat

echo [3/4] Установка зависимостей...
python -m pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
    echo [ОШИБКА] Не удалось установить зависимости
    pause
    exit /b 1
)

echo [4/5] Создание .env файла...
if not exist ".env" (
    copy .env.example .env
    echo [INFO] Файл .env создан. Откройте его и добавьте BOT_TOKEN
    notepad .env
) else (
    echo [INFO] Файл .env уже существует
)

echo [5/5] Установка FFmpeg...
where ffmpeg >nul 2>&1
if errorlevel 1 (
    echo [INFO] FFmpeg не найден. Устанавливаю...
    
    REM Проверка наличия winget
    where winget >nul 2>&1
    if not errorlevel 1 (
        echo [INFO] Установка через winget...
        winget install --id Gyan.FFmpeg -e --silent
        if not errorlevel 1 (
            echo [OK] FFmpeg установлен через winget
        ) else (
            echo [WARNING] Не удалось установить через winget
            goto :manual_ffmpeg
        )
    ) else (
        goto :manual_ffmpeg
    )
) else (
    echo [OK] FFmpeg уже установлен
)
goto :finish

:manual_ffmpeg
echo.
echo ========================================
echo   ТРЕБУЕТСЯ РУЧНАЯ УСТАНОВКА FFMPEG
echo ========================================
echo.
echo FFmpeg необходим для скачивания видео с YouTube
echo.
echo Вариант 1 - Через Chocolatey (рекомендуется):
echo   1. Установите Chocolatey: https://chocolatey.org/install
echo   2. Запустите: choco install ffmpeg
echo.
echo Вариант 2 - Ручная установка:
echo   1. Скачайте: https://github.com/BtbN/FFmpeg-Builds/releases
echo   2. Выберите: ffmpeg-master-latest-win64-gpl.zip
echo   3. Распакуйте в C:\ffmpeg
echo   4. Добавьте в PATH: C:\ffmpeg\bin
echo.
echo Вариант 3 - Через winget (Windows 11):
echo   winget install Gyan.FFmpeg
echo.
pause

:finish
echo.
echo ========================================
echo   Установка завершена!
echo ========================================
echo.
echo Следующие шаги:
echo 1. Добавьте BOT_TOKEN в файл .env
echo 2. Запустите start_bot.bat
echo.
pause
