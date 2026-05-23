---
tags:
  - skill
  - 自建
created: 2026-03-25
---

# content-to-knowledge-card

（个人专属）（自建）

将任意内容转化为知识卡片。支持三种来源：YouTube 视频、微信公众号文章、X/Twitter 推文。

## 触发词

知识卡片、视频转卡片、文章转卡片、推文转卡片、内容提炼、转录、视频转笔记，或给出 YouTube/微信/X 链接并要求提炼。

## 流程

1. **获取文字稿**：根据来源类型（YouTube/微信/X）用对应工具抓取
2. **提炼生图**：用专用提示词将文字稿提炼为知识卡片图片

## 获取方式

| 来源 | 优先方案 |
|------|----------|
| YouTube | summarize skill / 在线转录工具 |
| 微信文章 | openclaw browser + Playwright CDP |
| X/Twitter | autoglm-open-link / browser + Playwright |
| 直接文字 | 无需获取，直接提炼 |

## 卡片用途

- 小红书图文发布
- 公众号素材
- 存入 IMA 笔记 / Obsidian

## 实测记录

### 2026-03-25 首次测试（X Article）

**测试来源：** @PandaTalk8 的 X Article「CLAUDE CODE 最佳实践：从"能用"到"真的好用"」
**结果：** ✅ 成功生成知识卡片图片

**流程与踩坑：**

1. **抓取 X 推文**（4种方案尝试）：
   - ❌ AutoGLM Open Link：Token 服务（127.0.0.1:53699）未运行
   - ❌ web_fetch：X 页面需要 JS 渲染，直接抓取失败
   - ❌ openclaw browser open：命令退出码 1，无输出
   - ❌ summarize skill（bird/nitter）：bird 未安装，nitter 返回空
   - ✅ **fxtwitter API**：`api.fxtwitter.com/{user}/status/{id}/zh` 成功
   - ⚠️ **注意**：这是一篇 X Article（长文章），`tweet.text` 为空，完整内容在 `article.content.blocks` 里，需要遍历 blocks 提取文字

2. **生成图片**：
   - ❌ AutoGLM 生图：Token 服务未运行
   - ✅ **Seedream（火山引擎）**：使用 `doubao-seedream-5-0` 模型
   - ⚠️ Seedream 最低分辨率要求 **3,686,400 像素**（2048x2048），1536x2048 会被拒
   - ⚠️ **Windows PowerShell 不支持中文命令行参数**，必须写 Python 脚本执行，脚本内加 `sys.stdout.reconfigure(encoding='utf-8')`

3. **发送图片到飞书**：
   - 图片上传：`POST /im/v1/images`，需 `im:resource` 权限
   - 发送消息：`receive_id_type` 必须用 `open_id`（不是 `user_id`）
   - `ou_` 开头的 ID 是 open_id

4. **未完成环节**：
   - ❌ 自动审查图片质量：GLM-4.6V 返回 429（余额不足），无法调用图片分析模型验证生成效果

**fxtwitter 抓取 X Article 的 Python 脚本要点：**

```python
import urllib.request, json
r = urllib.request.urlopen(f'https://api.fxtwitter.com/{user}/status/{tweet_id}')
data = json.loads(r.read())
article = data['tweet']['article']
title = article['title']
blocks = article['content']['blocks']
for block in blocks:
    text = block.get('text', '')
    btype = block.get('type', '')
    # btype: header-one, header-two, header-three,
    #        unstyled, unordered-list-item, ordered-list-item, code-block
```

**改进建议：**

- [ ] 优先使用 fxtwitter API 作为 X 来源的默认方案（不需要 Token 服务）
- [ ] 增加 X Article 检测逻辑（`is_note_tweet` 或 `article` 字段非空）
- [ ] 图片自动审查环节需要备用模型（当前 GLM-4.6V 余额不足时完全跳过）
- [ ] Seedream 生图提示词中对中文引号的处理需要测试（`"能用"` vs `\"能用\"`）

## 文件位置

`~/.openclaw-autoclaw/skills/content-to-knowledge-card/SKILL.md`
