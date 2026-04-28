@echo off
chcp 65001 >nul
title TikTok Video Downloader Bot

echo ========================================
echo   TikTok Video Downloader Bot
echo ========================================
echo.

REM Проверка существования виртуального окружения
if not exist "venv\Scripts\activate.bat" (
    echo [ОШИБКА] Виртуальное окружение не найдено!
    echo Запустите: install.bat
    echo.
    pause
    exit /b 1
)

REM Проверка .env файла
if not exist ".env" (
    echo [ОШИБКА] Файл .env не найден!
    echo Скопируйте .env.example в .env и добавьте BOT_TOKEN
    echo.
    pause
    exit /b 1
)

REM Проверка FFmpeg
where ffmpeg >nul 2>&1
if errorlevel 1 (
    REM Проверка локальной установки FFmpeg
    if exist "%~dp0ffmpeg\bin\ffmpeg.exe" (
        echo [INFO] Использую локальный FFmpeg...
        set "PATH=%~dp0ffmpeg\bin;%PATH%"
    ) else (
        echo [WARNING] FFmpeg не найден!
        echo Для работы с YouTube необходим FFmpeg
        echo.
        echo Запустите install_ffmpeg.bat для установки
        echo Или нажмите любую клавишу для продолжения без FFmpeg
        echo (TikTok и Pinterest будут работать)
        echo.
        pause
    )
) else (
    echo [OK] FFmpeg найден
)

echo [INFO] Активация виртуального окружения...
call venv\Scripts\activate.bat

echo [INFO] Запуск бота...
echo.
python bot.py

REM Если бот упал, показать ошибку
if errorlevel 1 (
    echo.
    echo [ОШИБКА] Бот завершился с ошибкой!
    pause
)
