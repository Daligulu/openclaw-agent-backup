# TOOLS.md - Tool Configuration & Notes

> Document tool-specific configurations, gotchas, and credentials here.

---

## Credentials Location

All credentials stored in `.credentials/` (gitignored):
- `example-api.txt` — Example API key

---

## Obsidian Headless (ob CLI)

**Status:** ✅ Working

**Configuration:**
```
CLI: ob (v0.0.8)
Vault 路径: ~/Obsidian
设备名: OpenClaw-Agent
账号邮箱: gaojunfeng1108@gmail.com
远程仓库: 峰之宝库（远程）(0622325bd69824a29142496fb5f9001e)
同步模式: bidirectional（双向）
冲突策略: merge（合并）
E2E 密码: Grayson214
```

**Gotchas:**
- Linux 不支持 birthtime 保留，但不影响同步功能
- 首次同步可能较慢（增量式）
- 连续模式（--continuous）适合长时间运行

**Common Operations:**
```bash
# 登录
ob login --email gaojunfeng1108@gmail.com --password <密码>

# 列出远程仓库
ob sync-list-remote

# 设置同步
ob sync-setup --vault "峰之宝库（远程)" --path ~/Obsidian --device-name "OpenClaw-Agent" --password <E2E密码>

# 执行同步
ob sync --path ~/Obsidian

# 持续监听同步
ob sync --path ~/Obsidian --continuous

# 查看状态
ob sync-status --path ~/Obsidian

# 断开同步
ob sync-unlink --path ~/Obsidian
```

---

## WeWrite (微信公众号发布)

**Status:** ✅ Working

**多账号配置：**
- 峰AI路：`wx42b46ea46863a720`（默认）
- 狗狗生活小百科：`wx27855f8407f2c81c`

**⚠️ 关键 Gotcha（2026-05-04 记录）：**
publish 命令**不支持** `--account` 参数！默认只用 config.yaml 顶部的 appid/secret。

**切换账号方法：**
```bash
cp config.yaml config.yaml.bak
sed -i 's/appid: "原appid"/appid: "目标appid"/' config.yaml
sed -i 's/secret: "原secret"/secret: "目标secret"/' config.yaml
python3 toolkit/cli.py publish ...
mv config.yaml.bak config.yaml
```

**教训：** 不要假设 `--account` 参数可用，必须临时修改 config.yaml 的默认账号。

---

## Writing Preferences

[Document any preferences about writing style, voice, etc.]

---

## What Goes Here

- Tool configurations and settings
- Credential locations (not the credentials themselves!)
- Gotchas and workarounds discovered
- Common commands and patterns
- Integration notes

## Why Separate?

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

---

*Add whatever helps you do your job. This is your cheat sheet.*
