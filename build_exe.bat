@echo off
chcp 65001 >nul
title Сборка EXE файла

echo ========================================
echo   Сборка TikTok Bot в EXE
echo ========================================
echo.

REM Проверка venv
if not exist "venv\Scripts\activate.bat" (
    echo [ОШИБКА] Виртуальное окружение не найдено!
    echo Запустите install.bat сначала
    pause
    exit /b 1
)

echo [1/5] Активация виртуального окружения...
call venv\Scripts\activate.bat

echo [2/5] Установка PyInstaller...
pip install pyinstaller

echo [3/5] Создание EXE файла...
echo Это может занять несколько минут...
echo.

pyinstaller --onefile ^
    --name "TikTokBot" ^
    --hidden-import=aiogram ^
    --hidden-import=aiohttp ^
    --hidden-import=yt_dlp ^
    --hidden-import=dotenv ^
    bot.py

if errorlevel 1 (
    echo [ОШИБКА] Не удалось создать EXE
    pause
    exit /b 1
)

echo [4/5] Копирование дополнительных файлов...
copy .env.example dist\ >nul
copy README_WINDOWS.md dist\ >nul
copy install_ffmpeg.bat dist\ >nul
copy LICENSE dist\ >nul

echo [5/5] Создание README для portable версии...
(
echo TikTok Video Downloader Bot - Portable Edition
echo.
echo Быстрый старт:
echo 1. Создайте файл .env и добавьте BOT_TOKEN=ваш_токен
echo 2. Запустите install_ffmpeg.bat для установки FFmpeg
echo 3. Запустите TikTokBot.exe
echo.
echo Подробная инструкция: README_WINDOWS.md
echo.
echo GitHub: https://github.com/Nickwilde85/tiktok-bot-win
) > dist\README.txt

echo.
echo ========================================
echo   Сборка завершена!
echo ========================================
echo.
echo Файлы находятся в папке: dist\
echo.
echo Содержимое:
echo - TikTokBot.exe (главный файл)
echo - .env.example (шаблон конфигурации)
echo - install_ffmpeg.bat (установка FFmpeg)
echo - README_WINDOWS.md (инструкция)
echo - README.txt (быстрый старт)
echo.
echo Для создания установщика смотрите: BUILD_EXE.md
echo.
pause
