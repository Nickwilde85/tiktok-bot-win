import asyncio
import logging
import os
import tempfile
import re

from aiogram import Bot, Dispatcher, F, types
from aiogram.filters import Command
from aiogram.types import (
    Message, FSInputFile, URLInputFile, InputMediaPhoto
)
from dotenv import load_dotenv
import yt_dlp
import aiohttp

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BOT_TOKEN = os.getenv("BOT_TOKEN")
if not BOT_TOKEN:
    raise ValueError("BOT_TOKEN not set in .env file")

HTTP_PROXY = os.getenv("HTTP_PROXY")
HTTPS_PROXY = os.getenv("HTTPS_PROXY")

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()




def download_tiktok_video(url: str, output_path: str) -> str:
    """Download TikTok video in highest quality using yt-dlp."""
    ydl_opts = {
        'format': 'best',
        'outtmpl': output_path,
        'quiet': True,
        'no_warnings': True,
        'extract_flat': False,
        'http_headers': {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Referer': 'https://www.tiktok.com/',
        }
    }
    
    if HTTP_PROXY or HTTPS_PROXY:
        proxy = HTTPS_PROXY or HTTP_PROXY
        ydl_opts['proxy'] = proxy
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        return ydl.prepare_filename(info)


def normalize_tiktok_url(url: str) -> str:
    """Convert photo URLs to video format for yt-dlp compatibility."""
    # Replace /photo/ with /video/ for yt-dlp
    url = re.sub(r'/photo/', '/video/', url)
    return url


async def extract_tiktok_photos(url: str) -> list:
    """Extract photo URLs from TikTok photo post by parsing HTML."""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Referer': 'https://www.tiktok.com/',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    }
    
    async with aiohttp.ClientSession() as session:
        async with session.get(url, headers=headers) as response:
            html = await response.text()
    
    # Try to extract from JSON data in the page
    # TikTok stores data in __NEXT_DATA__ or similar script tags
    photo_urls = []
    
    # Pattern 1: Look for image URLs in the HTML (broader patterns)
    patterns = [
        r'https://[^"\'\\s]*tiktokcdn\.com[^"\'\\s]*',
        r'https://[^"\'\\s]*byteimg\.com[^"\'\\s]*',
        r'https://[^"\'\\s]*tiktok\.com[^"\'\\s]*img[^"\'\\s]*',
    ]
    
    for pattern in patterns:
        matches = re.findall(pattern, html)
        for match in matches:
            # Clean up the URL (remove trailing characters)
            clean_url = match.split('?')[0].split('&')[0]
            if clean_url not in photo_urls:
                photo_urls.append(clean_url)
    
    # Pattern 2: Try to find JSON data with image URLs
    json_patterns = [
        r'"imagePost":\s*\{[^}]*"images":\s*\[([^\]]+)\]',
        r'"images":\s*\[([^\]]+)\]',
        r'"url":\s*"([^"]*tiktokcdn[^"]*)"',
        r'"url":\s*"([^"]*byteimg[^"]*)"',
    ]
    
    for pattern in json_patterns:
        matches = re.findall(pattern, html)
        for match in matches:
            if isinstance(match, str):
                if match not in photo_urls:
                    photo_urls.append(match)
            else:
                for m in match:
                    if isinstance(m, str) and m not in photo_urls:
                        photo_urls.append(m)
    
    # Filter only image URLs
    image_urls = []
    for url in photo_urls:
        if any(ext in url for ext in ['.jpg', '.jpeg', '.png', '.webp']):
            if url not in image_urls:
                image_urls.append(url)
    
    logger.info(f"Extracted {len(image_urls)} image URLs from HTML")
    return image_urls[:10]  # Limit to 10 photos


def download_video_content(url: str, temp_dir: str) -> dict:
    """Download video content from TikTok, YouTube, or Pinterest using yt-dlp."""
    # Check if it's a TikTok photo post
    if '/photo/' in url and 'tiktok.com' in url:
        # Return marker that this needs async photo extraction
        return {'type': 'photos_async', 'url': url}
    
    # It's a video - download it with yt-dlp
    output_path = os.path.join(temp_dir, "video.%(ext)s")
    
    # Determine platform for appropriate headers
    if 'tiktok.com' in url:
        referer = 'https://www.tiktok.com/'
    elif 'youtube.com' in url or 'youtu.be' in url:
        referer = 'https://www.youtube.com/'
    elif 'pinterest.com' in url or 'pin.it' in url:
        referer = 'https://www.pinterest.com/'
    else:
        referer = url
    
    ydl_opts = {
        'format': 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best',
        'outtmpl': output_path,
        'quiet': True,
        'no_warnings': True,
        'merge_output_format': 'mp4',
        'http_headers': {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            'Referer': referer,
        }
    }
    
    if HTTP_PROXY or HTTPS_PROXY:
        proxy = HTTPS_PROXY or HTTP_PROXY
        ydl_opts['proxy'] = proxy
    
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(url, download=True)
        video_path = ydl.prepare_filename(info)
        return {
            'type': 'video',
            'path': video_path,
            'title': info.get('title', 'Video'),
            'webpage_url': info.get('webpage_url', url)
        }


@dp.message(Command("start"))
async def cmd_start(message: Message):
    await message.answer(
        "👋 Привет! Я бот для скачивания видео.\n\n"
        "📱 Поддерживаемые платформы:\n"
        "• TikTok (видео и фото)\n"
        "• YouTube\n"
        "• Pinterest\n\n"
        "⚡️ Просто отправь мне ссылку, и я скачаю контент в максимальном качестве!"
    )


@dp.message(Command("help"))
async def cmd_help(message: Message):
    await message.answer(
        "📋 <b>Как использовать:</b>\n"
        "1. Отправь ссылку на видео\n"
        "2. Дождись загрузки\n"
        "3. Получи контент в максимальном качестве!\n\n"
        "🔗 <b>Поддерживаемые платформы:</b>\n"
        "• TikTok: vm.tiktok.com, tiktok.com/@user/video, tiktok.com/@user/photo\n"
        "• YouTube: youtube.com/watch?v=, youtu.be/\n"
        "• Pinterest: pinterest.com/pin/, pin.it/",
        parse_mode="HTML"
    )


async def process_download(message: Message, url: str):
    """Download and send content (video or photos) to the chat."""
    logger.info(f"Processing URL: {url}")
    status_message = await message.answer("⏳ Скачиваю контент в максимальном качестве...")
    
    try:
        # Clean URL - remove playlist parameters
        from urllib.parse import urlparse, parse_qs
        parsed = urlparse(url)
        query_params = parse_qs(parsed.query)
        # Keep only 'v' parameter for YouTube, remove others like 'list'
        if 'youtube.com' in url or 'youtu.be' in url:
            if 'v' in query_params:
                clean_query = f"v={query_params['v'][0]}"
                url = f"{parsed.scheme}://{parsed.netloc}{parsed.path}?{clean_query}"
        
        # Normalize URL for yt-dlp (convert /photo/ to /video/ for TikTok)
        url = normalize_tiktok_url(url)
        logger.info(f"Normalized URL: {url}")
        
        # Download with yt-dlp
        await status_message.edit_text("📤 Отправляю видео...")
        
        with tempfile.TemporaryDirectory() as temp_dir:
            loop = asyncio.get_event_loop()
            content = await loop.run_in_executor(
                None, download_video_content, url, temp_dir
            )
            
            video_file = FSInputFile(content['path'])
            await message.answer_video(
                video=video_file,
                caption=f"✅ Готово! Видео скачано в максимальном качестве.\n\n🔗 {content['webpage_url']}",
                supports_streaming=True
            )
            
            await status_message.delete()
            
    except Exception as e:
        logger.error(f"Error downloading content: {e}")
        await status_message.edit_text(
            "❌ Ошибка при скачивании контента.\n"
            "Проверьте ссылку и попробуйте снова."
        )


@dp.message(F.text.regexp(r'https?://(?:www\.)?(?:tiktok\.com|vm\.tiktok\.com|vt\.tiktok\.com|youtube\.com|youtu\.be|pinterest\.com|pin\.it)/.+'))
async def download_video(message: Message):
    url = message.text.strip()
    await process_download(message, url)


@dp.message()
async def unknown_message(message: Message):
    await message.answer(
        "🤔 Я не понимаю это сообщение.\n"
        "Отправь мне ссылку на видео (TikTok, YouTube, Pinterest) или используй /help"
    )


async def main():
    logger.info("Starting bot...")
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())
