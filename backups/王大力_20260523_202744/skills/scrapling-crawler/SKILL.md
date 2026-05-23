---
name: scrapling-crawler
description: 基于 Scrapling 的网页爬取 Skill，支持静态和动态页面爬取、数据提取、自适应解析等功能。自建 Skill。
metadata:
  emoji: 🕷️
  author: OpenClaw User
  version: 1.0.0
  type: self-hosted
  requirements:
    - Python 3.12+
    - Scrapling 0.4.2
    - Playwright
---

# Scrapling Crawler Skill

基于 Scrapling 框架的网页爬取工具，支持多种爬取模式和数据提取功能。

## 功能特性

- ✅ 静态页面爬取 (Fetcher)
- ✅ 动态页面爬取 (StealthyFetcher)
- ✅ 异步并发请求 (AsyncFetcher)
- ✅ CSS/XPath 选择器解析
- ✅ 自适应解析 (页面结构变化自动适配)
- ✅ Spider 爬虫框架
- ✅ 表单提交、Cookie/Session 管理
- ✅ 反爬虫绕过

## 安装

```bash
# 激活虚拟环境
source ~/scrapling-env/bin/activate

# 已预装依赖
# - scrapling==0.4.2
# - playwright==1.58.0
# - patchright==1.58.2
```

## 使用方法

### 1. 基础爬取

```python
from scrapling.fetchers import Fetcher

fetcher = Fetcher()
response = fetcher.get('https://example.com')

# 提取数据
title = response.css('title::text').get()
links = response.css('a::attr(href)').getall()
```

### 2. 浏览器模式 (动态页面)

```python
from scrapling.fetchers import StealthyFetcher

fetcher = StealthyFetcher()
response = fetcher.fetch(
    'https://example.com',
    headless=True,
    network_idle=True
)
```

### 3. 异步并发

```python
from scrapling.fetchers import AsyncFetcher
import asyncio

async def crawl():
    fetcher = AsyncFetcher()
    urls = ['https://site1.com', 'https://site2.com']
    tasks = [fetcher.get(url) for url in urls]
    responses = await asyncio.gather(*tasks)

asyncio.run(crawl())
```

### 4. Spider 框架

```python
from scrapling.spiders import Spider, Response

class MySpider(Spider):
    name = "my_spider"
    start_urls = ["https://example.com"]
    
    async def parse(self, response: Response):
        title = response.css('h1::text').get()
        yield {"title": title}

MySpider().start()
```

## CLI 使用

```bash
# 激活环境后使用
source ~/scrapling-env/bin/activate

# 获取页面并保存
scrapling extract get <URL> <output_file>

# 使用浏览器模式
scrapling extract stealthy-fetch <URL> <output_file>
```

## 虚拟环境

- **路径**: `~/scrapling-env`
- **Python**: 3.12.3
- **Scrapling**: 0.4.2

## 注意事项

1. 使用前需激活虚拟环境: `source ~/scrapling-env/bin/activate`
2. 浏览器模式首次运行可能需要下载 Chromium
3. 部分网站可能需要 StealthyFetcher 绕过反爬

## 依赖列表

```
scrapling==0.4.2
playwright==1.58.0
patchright==1.58.2
curl_cffi==0.14.0
browserforge==1.2.4
msgspec==0.20.0
anyio==4.13.0
lxml==6.0.2
orjson==3.11.7
```

---
*自建 Skill - 基于 Scrapling 框架*
