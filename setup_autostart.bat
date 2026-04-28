@echo off
chcp 65001 >nul
title Настройка автозапуска бота

echo ========================================
echo   Настройка автозапуска
echo ========================================
echo.

REM Получить текущую директорию
set "CURRENT_DIR=%~dp0"
set "BAT_FILE=%CURRENT_DIR%start_bot.bat"

echo Текущая директория: %CURRENT_DIR%
echo Файл запуска: %BAT_FILE%
echo.

REM Проверка файла
if not exist "%BAT_FILE%" (
    echo [ОШИБКА] Файл start_bot.bat не найден!
    pause
    exit /b 1
)

echo Создание задачи в планировщике заданий...
echo.

REM Создание XML конфигурации для Task Scheduler
set "TASK_NAME=TikTokVideoBot"
set "XML_FILE=%TEMP%\tiktok_bot_task.xml"

(
echo ^<?xml version="1.0" encoding="UTF-16"?^>
echo ^<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"^>
echo   ^<RegistrationInfo^>
echo     ^<Description^>TikTok Video Downloader Bot - автозапуск^</Description^>
echo   ^</RegistrationInfo^>
echo   ^<Triggers^>
echo     ^<LogonTrigger^>
echo       ^<Enabled^>true^</Enabled^>
echo     ^</LogonTrigger^>
echo   ^</Triggers^>
echo   ^<Principals^>
echo     ^<Principal^>
echo       ^<LogonType^>InteractiveToken^</LogonType^>
echo       ^<RunLevel^>LeastPrivilege^</RunLevel^>
echo     ^</Principal^>
echo   ^</Principals^>
echo   ^<Settings^>
echo     ^<MultipleInstancesPolicy^>IgnoreNew^</MultipleInstancesPolicy^>
echo     ^<DisallowStartIfOnBatteries^>false^</DisallowStartIfOnBatteries^>
echo     ^<StopIfGoingOnBatteries^>false^</StopIfGoingOnBatteries^>
echo     ^<AllowHardTerminate^>true^</AllowHardTerminate^>
echo     ^<StartWhenAvailable^>true^</StartWhenAvailable^>
echo     ^<RunOnlyIfNetworkAvailable^>true^</RunOnlyIfNetworkAvailable^>
echo     ^<AllowStartOnDemand^>true^</AllowStartOnDemand^>
echo     ^<Enabled^>true^</Enabled^>
echo     ^<Hidden^>false^</Hidden^>
echo     ^<ExecutionTimeLimit^>PT0S^</ExecutionTimeLimit^>
echo   ^</Settings^>
echo   ^<Actions^>
echo     ^<Exec^>
echo       ^<Command^>"%BAT_FILE%"^</Command^>
echo       ^<WorkingDirectory^>%CURRENT_DIR%^</WorkingDirectory^>
echo     ^</Exec^>
echo   ^</Actions^>
echo ^</Task^>
) > "%XML_FILE%"

REM Импорт задачи
schtasks /Create /TN "%TASK_NAME%" /XML "%XML_FILE%" /F

if errorlevel 1 (
    echo.
    echo [ОШИБКА] Не удалось создать задачу!
    echo Попробуйте запустить этот файл от имени администратора
    del "%XML_FILE%"
    pause
    exit /b 1
)

del "%XML_FILE%"

echo.
echo ========================================
echo   Автозапуск настроен!
echo ========================================
echo.
echo Задача "%TASK_NAME%" создана в планировщике заданий
echo Бот будет запускаться автоматически при входе в систему
echo.
echo Управление:
echo - Открыть планировщик: taskschd.msc
echo - Удалить задачу: schtasks /Delete /TN "%TASK_NAME%" /F
echo.
pause
