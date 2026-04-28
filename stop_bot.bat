@echo off
chcp 65001 >nul
title Остановка бота

echo ========================================
echo   Остановка бота
echo ========================================
echo.

echo Поиск процессов Python с bot.py...
for /f "tokens=2" %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO LIST ^| findstr /I "PID"') do (
    wmic process where "ProcessId=%%i" get CommandLine 2>nul | findstr /I "bot.py" >nul
    if not errorlevel 1 (
        echo Остановка процесса %%i...
        taskkill /PID %%i /F
    )
)

echo.
echo Готово!
timeout /t 2 >nul
