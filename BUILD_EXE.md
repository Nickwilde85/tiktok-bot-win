# 📦 Создание EXE версии бота

## Способ 1: PyInstaller (рекомендуется)

### Установка PyInstaller
```cmd
venv\Scripts\activate
pip install pyinstaller
```

### Создание EXE
```cmd
pyinstaller --onefile --name "TikTokBot" --icon=icon.ico bot.py
```

Параметры:
- `--onefile` - один exe файл
- `--name` - имя файла
- `--icon` - иконка (опционально)
- `--noconsole` - без консоли (не рекомендуется для бота)

### Создание EXE с зависимостями
```cmd
pyinstaller --onedir --name "TikTokBot" bot.py
```

Результат в папке `dist/`

## Способ 2: Auto-py-to-exe (GUI)

### Установка
```cmd
venv\Scripts\activate
pip install auto-py-to-exe
```

### Запуск
```cmd
auto-py-to-exe
```

В GUI:
1. Script Location: выберите `bot.py`
2. Onefile: One File
3. Console Window: Console Based
4. Additional Files: добавьте `.env.example`
5. Convert .py to .exe

## Способ 3: Nuitka (самый быстрый)

### Установка
```cmd
pip install nuitka
```

### Создание EXE
```cmd
python -m nuitka --onefile --windows-disable-console bot.py
```

## 📦 Создание установщика

### Inno Setup (рекомендуется)

1. Скачайте Inno Setup: https://jrsoftware.org/isdl.php
2. Создайте файл `installer.iss`:

```iss
[Setup]
AppName=TikTok Video Downloader Bot
AppVersion=1.0
DefaultDirName={pf}\TikTokBot
DefaultGroupName=TikTok Bot
OutputDir=output
OutputBaseFilename=TikTokBot-Setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "dist\TikTokBot.exe"; DestDir: "{app}"
Source: ".env.example"; DestDir: "{app}"
Source: "README_WINDOWS.md"; DestDir: "{app}"
Source: "install_ffmpeg.bat"; DestDir: "{app}"

[Icons]
Name: "{group}\TikTok Bot"; Filename: "{app}\TikTokBot.exe"
Name: "{group}\Установка FFmpeg"; Filename: "{app}\install_ffmpeg.bat"
Name: "{group}\Readme"; Filename: "{app}\README_WINDOWS.md"

[Run]
Filename: "{app}\TikTokBot.exe"; Description: "Запустить бота"; Flags: postinstall nowait skipifsilent
```

3. Откройте в Inno Setup и скомпилируйте

## 🎯 Рекомендуемая структура для EXE

### Вариант 1: Portable (портативная версия)
```
TikTokBot-Portable/
├── TikTokBot.exe
├── .env.example
├── README.txt
├── install_ffmpeg.bat
└── ffmpeg/ (опционально)
    └── bin/
        └── ffmpeg.exe
```

### Вариант 2: Installer (установщик)
Создайте установщик через Inno Setup, который:
- Устанавливает бот в Program Files
- Создает ярлыки в меню Пуск
- Предлагает установить FFmpeg
- Создает .env файл при первом запуске

## ⚠️ Важные замечания

### Проблемы с PyInstaller
1. **Антивирусы** могут блокировать exe файлы
   - Решение: подпишите exe цифровой подписью
   - Или добавьте в исключения антивируса

2. **Размер файла** будет большим (50-100 МБ)
   - Это нормально, включает Python и все библиотеки

3. **Скрытые импорты**
   - Если бот не работает, добавьте:
   ```cmd
   pyinstaller --onefile --hidden-import=aiogram --hidden-import=yt_dlp bot.py
   ```

### .env файл
EXE файл должен искать .env в той же папке:
```python
import os
import sys

# Получить путь к папке с exe
if getattr(sys, 'frozen', False):
    application_path = os.path.dirname(sys.executable)
else:
    application_path = os.path.dirname(__file__)

# Загрузить .env из папки с exe
env_path = os.path.join(application_path, '.env')
load_dotenv(env_path)
```

## 🚀 Быстрый старт

### Создание простого EXE
```cmd
REM Активировать venv
venv\Scripts\activate

REM Установить PyInstaller
pip install pyinstaller

REM Создать EXE
pyinstaller --onefile --name "TikTokBot" bot.py

REM Скопировать необходимые файлы
copy .env.example dist\
copy README_WINDOWS.md dist\
copy install_ffmpeg.bat dist\

REM Готово! EXE в папке dist\
```

### Тестирование
1. Перейдите в `dist/`
2. Создайте `.env` файл с BOT_TOKEN
3. Запустите `TikTokBot.exe`

## 📝 Автоматизация сборки

Создайте `build_exe.bat`:
```batch
@echo off
echo Сборка EXE...

call venv\Scripts\activate
pip install pyinstaller

pyinstaller --onefile ^
    --name "TikTokBot" ^
    --add-data ".env.example;." ^
    --hidden-import=aiogram ^
    --hidden-import=yt_dlp ^
    bot.py

copy install_ffmpeg.bat dist\
copy README_WINDOWS.md dist\

echo Готово! Проверьте папку dist\
pause
```

## 🎁 Распространение

### GitHub Release
1. Создайте Release на GitHub
2. Загрузите:
   - `TikTokBot.exe`
   - `TikTokBot-Setup.exe` (установщик)
   - `README_WINDOWS.md`

### Описание Release
```markdown
## TikTok Video Downloader Bot v1.0

### Скачать:
- **Portable версия**: TikTokBot.exe (не требует установки)
- **Установщик**: TikTokBot-Setup.exe (рекомендуется)

### Требования:
- Windows 10/11
- FFmpeg (установится автоматически)

### Первый запуск:
1. Скачайте и запустите
2. Создайте .env файл с BOT_TOKEN
3. Установите FFmpeg (если нужен YouTube)
4. Готово!
```
