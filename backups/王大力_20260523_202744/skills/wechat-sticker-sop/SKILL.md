---
name: wechat-sticker-sop
description: 微信服务号贴图制作一站式SOP。输入主题，自动走完「信息调研→文案生成→配图方案→候选图生成→组装→发布草稿」全流程。整合tavily-search信息收集、xiaohongshu-writer-expert文案能力、image-generation/seedream5配图能力、wechat-sticker-publisher发布能力。
version: 1.5.0
---

# 微信服务号贴图制作 SOP

一站式微信公众号贴图制作工作流：从主题输入到草稿发布，全流程自动化（人工挑选环节除外）。

## 触发条件

### 精确触发词
- 做贴图、制作贴图、发贴图
- 微信贴图、公众号贴图
- **wss**、**WSS**（简写触发）

### 模式匹配
- 制作.*贴图、做.*贴图、发.*贴图
- 微信.*贴图、公众号.*贴图
- 贴图.*制作、贴图.*发布
- 图片消息、sticker、wechat.*sticker

## 流程总览

```
主题输入 → 信息调研 → 文案&配图方案 → 候选配图生成 → 人工挑选 → 组装排版 → 发布草稿
  (Step 0)   (Step 1)     (Step 2)        (Step 3)       (Step 4)    (Step 5)
```

## 前置条件

| 条件 | 必需 | 说明 |
|------|------|------|
| tavily-search skill | ✅ | 信息调研 |
| xiaohongshu-writer-expert skill | ✅ | 文案和配图方案生成 |
| **image-generation** skill | ✅ | **首选** AI 文生图（通过 ApiYi 代理，gpt-image-2 / gpt-image-2-all） |
| **seedream5** skill | ✅ | **备选** AI 文生图（火山方舟，Seedream 5.0） |
| wechat-sticker-publisher skill | ✅ | 贴图草稿发布 |
| TAVILY_API_KEY | ✅ | Tavily 搜索 API |
| OPENAI_API_KEY | ✅ | Image Generation API（ApiYi 代理） |
| VOLC_API_KEY 或 ARK_API_KEY | ✅ | Seedream 5.0 API（火山方舟） |
| WECHAT_APP_ID | ✅ | 微信公众号 AppID |
| WECHAT_APP_SECRET | ✅ | 微信公众号 AppSecret |

## 工作流程

### Step 0：信息调研

在文案创作前，先搜索主题相关最新资讯，提取关键信息形成调研摘要。

**操作**：
```bash
node <skill_dir>/../tavily-search/scripts/search.mjs "主题关键词" -n 5
```

### Step 1：文案 & 配图方案生成

基于 Step 0 的调研摘要，调用 `xiaohongshu-writer-expert` skill 生成：
- 📝 小红书风格文案（标题 + 正文 + 标签）
- 🎨 配图方案（画面描述 + 封面文案 + 搜索关键词）

### Step 2：候选配图生成（双引擎并行）

根据 Step 1 的配图方案，**同时调用两个 AI 生图引擎**，共生成 3-4 张候选图。优先使用知识科普卡风格的信息图 prompt（见下方模板），生成竖版中文信息图。

#### 🎨 引擎 A — Image Generation（首选）

通过 ApiYi 代理调用 OpenAI GPT Image 系列模型，走 chat/completions 接口。

**⚠️ 模型选择策略（重要）**：
- **优先用 `gpt-image-2-all`**：该模型路由到多个后端渠道，可用性更高，2026-05-15 实测信息图效果优秀
- **`gpt-image-2` 作为备选**：单一渠道，负载饱和时容易 429
- 当首选模型返回 `z_rate_limit` 或负载饱和错误时，自动切换到另一个

```bash
# 文生图（通过 curl，增加等待时间至 180 秒）
# ⚠️ 优先用 gpt-image-2-all，负载饱和时切换 gpt-image-2
curl -s --max-time 180 -X POST "https://api.apiyi.com/v1/chat/completions" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-image-2-all",
    "messages": [{"role": "user", "content": "{信息图prompt}"}]
  }'
```

**响应格式**：gpt-image-2-all 可能返回图片 URL（非 base64），需额外下载：
```bash
# 从响应中提取图片 URL 并下载
curl -sL "<response_image_url" -o output.png
```

**特点**：
- ✅ 已验证可用：`gpt-image-2-all`（首选）和 `gpt-image-2`（备选）
- ✅ 支持文生图、图生图（多模态）
- ✅ 国内直连（ApiYi 代理），无需翻墙
- ✅ 质量高，中文信息图渲染精准
- ⚠️ 需较长等待时间（建议 --max-time 180）
- ⚠️ gpt-image-2-all 返回图片 URL，gpt-image-2 返回 base64，需分别处理

#### 🖼️ 引擎 B — Seedream 5.0（备选）

```bash
# 文生图
uv run <skill_dir>/../seedream5/scripts/generate_image.py \
  --prompt "{信息图prompt}" \
  --filename "cover_1.png" \
  --resolution 2K \
  --aspect-ratio 3:4

# 图生图（基于参考图）
uv run <skill_dir>/../seedream5/scripts/generate_image.py \
  --prompt "{编辑指令}" \
  --filename "cover_2.png" \
  -i "reference.png" \
  --resolution 2K
```

**特点**：
- ✅ 支持文生图、图生图（最多14张参考图）
- ✅ 支持组图生成（sequential）
- ✅ 支持联网搜索（web-search）
- ✅ 支持去水印（no-watermark）
- 📐 分辨率：2K、3K
- 📐 比例：1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9
- ⚠️ 需要 VOLC_API_KEY 或 ARK_API_KEY

#### 📐 信息图 Prompt 模板

生成信息图时，优先使用以下知识科普卡模板，将 Step 1 的文案内容填入具体要点：

```
画一张3:4竖版中文知识科普信息图，主题为【主题】。

整体风格：现代百科风格，兼具图鉴感与信息结构感，像一本高级百科全书的跨页内页。

布局要求：
- 顶部：粗体衬线大标题 + 一句话副标题（灰色细体）
- 左侧或上方：一幅主视觉插画（扁平矢量风格，低饱和配色），占画面约1/3
- 右侧或下方：3-4个圆角模块化信息卡片，2×2网格排列，整齐对齐
- 每张卡片：小号加粗中文标签 + 一句话核心洞察 + 一个放大的关键数字或关键词

配色：主色【指定颜色】+ 浅灰背景 + 白色卡片 + 少量点缀色

文字要求：
- 标题用粗体衬线体，正文用黑体
- 缩略图尺寸下仍清晰可读
- 所有中文100%准确，禁止乱码，中文渲染质量拉满

约束：不是杂志封面，不是电影海报，不是广告图，是知识科普信息图。不要水印、不要logo、不要多余装饰元素。纯净白底，轻阴影，整洁排版，信息密度高但不拥挤。
```

#### 📊 最终输出

| 来源 | 数量 | 特点 | 用途 |
|------|------|------|------|
| **Image Generation** | 2 张 | AI 创意图（gpt-image-2-all / gpt-image-2） | 封面 + 内容图候选 |
| **Seedream 5.0** | 1-2 张 | AI 创意图（火山方舟） | 备选封面 + 内容图 |
| **合计** | **3-4 张** | 多样化选择 | 用户挑选 |

### Step 3：人工挑选

agent 展示所有候选图，用户选择：
- ✅ 封面图（必选 1 张）
- ✅ 内容配图（可选 0-N 张）

### Step 4：组装排版 & 发布草稿

使用 `wechat-sticker-publisher` skill 将选中图片组装成贴图草稿：

```bash
python3 <skill_dir>/../wechat-sticker-publisher/scripts/publish_sticker.py \
  --image /path/to/封面.jpg \
  --image /path/to/内容图1.jpg \
  --title "贴图标题" \
  --text "配文内容"
```

### Step 5：手动发布

提醒用户：
1. 登录微信公众号后台
2. 进入「草稿箱」
3. 预览贴图效果
4. 确认后点击「发布」

## 完整对话示例

```
用户：wss AI办公提效

Agent：
0. [Step 0] 信息调研 → 获取最新趋势 ✅
1. [Step 1] 生成文案 + 配图方案 ✅
2. [Step 2] 双引擎生图：
   ├── Image Generation 图 × 2（AI创意图，gpt-image-2-all 首选 / gpt-image-2 备选）✅
   └── Seedream 5.0 图 × 1-2（火山方舟）✅
   → 共 3-4 张候选图
3. [Step 3] 展示候选图 → 等待用户挑选
4. 用户选中封面图和内容图
5. [Step 4] 调用贴图skill → 组装并发布到草稿箱 ✅
6. [Step 5] 提醒用户去公众号后台手动发布
```

## 输出记录

每次执行会在 wechat-sticker-publisher 的 `outputs/` 目录生成 JSON 记录。

## 注意事项

1. **不自动发布**：草稿创建后必须手动在公众号后台确认发布
2. **图片格式**：支持 JPG/PNG，建议 3:4 竖版
3. **编码问题**：请求体必须使用 UTF-8
4. **图片数量**：单篇贴图最多 20 张
5. **封面图**：第一张图自动成为封面
