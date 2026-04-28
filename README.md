# 🎬 Video Downloader Bot

<div align="center">

![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)
![aiogram](https://img.shields.io/badge/aiogram-3.x-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Telegram](https://img.shields.io/badge/Telegram-Bot-blue.svg)
![Windows](https://img.shields.io/badge/Windows-10%2F11-blue.svg)

**Telegram бот для скачивания видео из TikTok, YouTube и Pinterest в максимальном качестве**

[⚡️ Возможности](#-возможности) • [🚀 Установка](#-установка) • [💻 Использование](#-использование) • [🪟 Windows](README_WINDOWS.md)

</div>

---

## ✨ Возможности

- 🎥 **Скачивание видео** в максимальном качестве
- 📸 **Поддержка фото/слайдов** — отправка до 10 изображений (TikTok)
- ⚡ **Параллельные загрузки** — неограниченное количество пользователей
-  **Автоматическая очистка** — временные файлы удаляются
- 🔗 **Множество платформ** — TikTok, YouTube, Pinterest

## 🚀 Установка

> 🪟 **Пользователи Windows**: Смотрите [подробную инструкцию для Windows](README_WINDOWS.md)

### Требования
- Python 3.9+
- Telegram Bot Token (получить у [@BotFather](https://t.me/BotFather))
- Windows 10/11 (или Linux/Mac)

### Шаги

1. **Клонируйте репозиторий**
```bash
git clone https://github.com/Nickwilde85/tiktok-bot-win.git
cd tiktok-bot-win
```

2. **Создайте виртуальное окружение**
```bash
python -m venv venv
venv\Scripts\activate
```

3. **Установите зависимости**
```bash
pip install -r requirements.txt
```

4. **Настройте окружение**
```bash
copy .env.example .env
notepad .env
```
Добавьте ваш `BOT_TOKEN` и сохраните файл

## 🔑 Получение токена

1. Напишите [@BotFather](https://t.me/BotFather) в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Скопируйте токен в файл `.env`

## ▶️ Запуск

### Ручной запуск
```bash
venv\Scripts\activate
python bot.py
```

### Быстрый запуск (двойной клик)
Запустите файл `start_bot.bat`

### Автозапуск при старте Windows
1. Откройте Task Scheduler (Планировщик заданий)
2. Создайте новую задачу:
   - Триггер: При входе в систему
   - Действие: Запустить `start_bot.bat`
   - Настройки: Запускать независимо от входа пользователя

Или используйте готовый скрипт:
```bash
setup_autostart.bat
```

## 💻 Использование

1. Найдите бота в Telegram
2. Отправьте `/start`
3. Отправьте ссылку на видео (TikTok, YouTube, Pinterest)
4. Получите контент в максимальном качестве!

## 🔗 Поддерживаемые ссылки

**TikTok:**
- `https://vm.tiktok.com/xxxxx` — короткие ссылки
- `https://vt.tiktok.com/xxxxx` — короткие ссылки
- `https://www.tiktok.com/@user/video/xxxxx` — видео
- `https://www.tiktok.com/@user/photo/xxxxx` — фото/слайды

**YouTube:**
- `https://www.youtube.com/watch?v=xxxxx` — видео
- `https://youtu.be/xxxxx` — короткие ссылки

**Pinterest:**
- `https://www.pinterest.com/pin/xxxxx` — пины
- `https://pin.it/xxxxx` — короткие ссылки

##  Технологии

- **Python 3.9+** — основной язык
- **aiogram 3.x** — Telegram Bot API
- **yt-dlp** — скачивание видео

## 📝 Лицензия

MIT License — свободно используйте в своих проектах

## 🤝 Вклад

Pull requests приветствуются!
