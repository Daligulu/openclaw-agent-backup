---
name: x-publish
description: |
  发布推文到 X (Twitter) 草稿箱。使用 Playwright 浏览器自动化，通过 Cookie 认证登录 X，
  将推文内容保存为草稿，永不自动发布。支持纯文本推文和推文线程（Thread）。
  触发关键词：发布推文、发推、X草稿、Twitter草稿、推文发布、存草稿。
allowed-tools:
  - Bash
  - Read
  - Write
---

# X-Publish — 推文草稿发布工具

## 行为声明

**角色**：将用户提供的推文内容保存到 X (Twitter) 草稿箱。

**安全原则**：
- 🔒 **永不自动发布** — 只保存到草稿箱，必须用户手动审核后发布
- 🍪 **Cookie 认证** — 使用用户提供的 Cookie 登录，不存储密码
- 📝 **日志记录** — 每次操作记录到事件日志

## 前提条件

### 1. 安装依赖

```bash
pip3 install playwright --user --break-system-packages
playwright install chromium
```

### 2. 配置 Cookie

用户需提供 X 的 Cookie，存储在环境变量或配置文件中：

```bash
# 方式一：环境变量
export X_AUTH_TOKEN="your_auth_token"
export X_CT0="your_ct0_token"

# 方式二：配置文件 ~/.x-publish/cookies.json
{
  "auth_token": "your_auth_token",
  "ct0": "your_ct0_token"
}
```

**获取 Cookie 方法：**
1. 在浏览器中登录 X (twitter.com)
2. 打开开发者工具 → Application → Cookies
3. 复制 `auth_token` 和 `ct0` 两个值

## 使用方法

### 保存单条推文到草稿

```bash
python3 scripts/x_publish.py --tweet "推文内容"
```

### 保存推文线程到草稿

```bash
python3 scripts/x_publish.py --thread "第一条" "第二条" "第三条"
```

### 验证 Cookie 是否有效

```bash
python3 scripts/x_publish.py --verify
```

## 输出格式

成功：
```
✅ 推文已保存到草稿箱！
📝 内容预览: 推文内容...
🔗 请前往 X 草稿箱审核并发布
```

失败：
```
❌ 保存失败: Cookie 已过期，请更新 Cookie
```

## 事件日志

每次操作记录到 `~/.x-publish/events.jsonl`：

```json
{
  "timestamp": "2026-04-29T15:00:00Z",
  "action": "save_draft",
  "tweet_count": 1,
  "status": "success",
  "content_preview": "推文内容前50字..."
}
```

## 注意事项

1. **Cookie 有效期** — X 的 Cookie 通常有效期较长，但可能因登出而失效
2. **频率限制** — 建议操作间隔 3-5 秒，避免触发 X 的反爬机制
3. **草稿箱位置** — X 的草稿箱在左侧菜单 → Drafts
4. **内容合规** — 遵守 X 平台规则，避免违规内容
