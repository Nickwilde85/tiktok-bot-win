@echo off
chcp 65001 >nul
title Очистка проекта для GitHub

echo ========================================
echo   Очистка проекта для GitHub
echo ========================================
echo.

echo [1/6] Удаление .env файла с токенами...
if exist ".env" (
    del /f /q ".env"
    echo ✓ .env удален
) else (
    echo ✓ .env уже отсутствует
)

echo [2/6] Удаление виртуального окружения...
if exist "venv" (
    rmdir /s /q "venv"
    echo ✓ venv удален
) else (
    echo ✓ venv уже отсутствует
)

echo [3/6] Удаление настроек IDE...
if exist ".vscode" (
    rmdir /s /q ".vscode"
    echo ✓ .vscode удален
) else (
    echo ✓ .vscode уже отсутствует
)

echo [4/6] Удаление Python кэша...
for /d /r . %%d in (__pycache__) do @if exist "%%d" rmdir /s /q "%%d"
del /s /q *.pyc 2>nul
del /s /q *.pyo 2>nul
echo ✓ Python кэш очищен

echo [5/6] Удаление логов...
del /s /q *.log 2>nul
echo ✓ Логи удалены

echo [6/6] Удаление временных файлов...
del /s /q *.tmp 2>nul
del /s /q Thumbs.db 2>nul
del /s /q desktop.ini 2>nul
del /s /q .DS_Store 2>nul
echo ✓ Временные файлы удалены

echo.
echo ========================================
echo   Проект готов для GitHub!
echo ========================================
echo.
echo Удалено:
echo • .env (токены и прокси)
echo • venv/ (виртуальное окружение)
echo • .vscode/ (настройки IDE)
echo • __pycache__/ (Python кэш)
echo • *.log (логи)
echo • Временные файлы
echo.
echo Следующие шаги:
echo 1. git add .
echo 2. git commit -m "Initial commit"
echo 3. git push
echo.
pause
