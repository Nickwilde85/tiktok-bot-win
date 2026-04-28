@echo off
chcp 65001 >nul
title Настройка нового репозитория

echo ========================================
echo   Создание репозитория tiktok-bot-win
echo ========================================
echo.

echo Шаг 1: Создайте новый репозиторий на GitHub
echo.
echo 1. Откройте: https://github.com/new
echo 2. Repository name: tiktok-bot-win
echo 3. Description: Telegram bot for downloading videos (Windows Edition)
echo 4. Public
echo 5. НЕ добавляйте README, .gitignore, license
echo 6. Create repository
echo.
pause

echo.
echo Шаг 2: Изменение remote URL...
git remote remove origin
git remote add origin https://github.com/Nickwilde85/tiktok-bot-win.git

echo.
echo Шаг 3: Добавление всех файлов...
git add .

echo.
echo Шаг 4: Создание коммита...
git commit -m "Initial commit: Windows-ready TikTok video downloader bot with FFmpeg support"

echo.
echo Шаг 5: Отправка на GitHub...
git branch -M main
git push -u origin main

echo.
echo ========================================
echo   Готово!
echo ========================================
echo.
echo Репозиторий доступен по адресу:
echo https://github.com/Nickwilde85/tiktok-bot-win
echo.
pause
