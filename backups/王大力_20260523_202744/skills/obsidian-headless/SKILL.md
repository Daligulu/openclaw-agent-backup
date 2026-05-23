---
name: obsidian-headless
description: |
  Headless client for Obsidian Sync. 命令行同步 Obsidian 远程仓库，无需桌面端。
  当用户提到"存到ob"、"保存到ob"、"推送到ob"、"同步ob"、"存到我的obsidian"、
  "推送到obsidian"、"同步obsidian"时，使用此 skill。
  **特别注意**：用户说"存到ob"是最常见且明确的触发词，必须优先响应。
version: 1.0.0
dependencies: []
allowed-tools:
  - exec
---

# Obsidian Headless Skill

Headless client for Obsidian Sync，命令行同步 Obsidian 远程仓库，无需桌面端。

## 前置要求

- Node.js 22+
- `obsidian-headless` 已安装: `npm install -g obsidian-headless`

## 配置信息

| 项目 | 值 |
|------|------|
| CLI | `ob` |
| Vault 路径 | `~/Obsidian` |
| 设备名 | `OpenClaw-Agent` |
| 账号邮箱 | `gaojunfeng1108@gmail.com` |
| 远程仓库 | 峰之宝库（远程）(`0622325bd69824a29142496fb5f9001e`) |
| 同步模式 | bidirectional（双向） |
| 冲突策略 | merge（合并） |

## 触发词

> **核心触发词（优先级最高）**：
> - **"存到ob"** / **"保存到ob"** —— 最常用表达，必须立即响应

- "存到我的 obsidian"
- "存到 ob" ⭐ **最常用**
- "保存到ob"
- "推送到 obsidian"
- "推送到ob"
- "同步 obsidian"
- "同步ob"

## 命令速查

### 登录/登出
```bash
ob login --email gaojunfeng1108@gmail.com --password <密码>
ob logout
```

### 远程仓库管理
```bash
ob sync-list-remote               # 列出所有远程仓库
ob sync-list-local                # 列出本地已配置仓库
```

### 同步执行
```bash
ob sync --path ~/Obsidian                    # 一次性同步
ob sync --path ~/Obsidian --continuous       # 持续监听同步（watch 模式）
```

### 状态与配置
```bash
ob sync-status --path ~/Obsidian    # 查看同步状态
ob sync-config --path ~/Obsidian    # 查看/修改配置
ob sync-unlink --path ~/Obsidian    # 断开同步
```

## 配置项详解

### Sync Mode（同步模式）
| 模式 | 说明 |
|------|------|
| `bidirectional` | 双向同步（默认） |
| `pull-only` | 仅拉取 |
| `mirror-remote` | 镜像远程 |

### Conflict Strategy（冲突策略）
| 策略 | 说明 |
|------|------|
| `merge` | 合并（默认） |
| `conflict` | 产生冲突文件 |

## 使用场景

### 场景 1：保存文件到 Obsidian
```bash
# 文件已保存到 ~/Obsidian，执行同步
ob sync --path ~/Obsidian
```

### 场景 2：持续同步（后台运行）
```bash
ob sync --path ~/Obsidian --continuous
```

### 场景 3：检查同步状态
```bash
ob sync-status --path ~/Obsidian
```

## 注意事项

- ⚠️ E2E 加密密码需要单独提供（不存储在 skill 中）
- ⚠️ 同步是增量式的，首次同步可能较慢
- ⚠️ Linux 不支持 birthtime 保留，但不影响同步功能
- ⚠️ 连续模式（`--continuous`）适合长时间运行

## 故障排查

### 登录失败
- 检查邮箱和密码
- 检查网络连接

### 同步失败
- 检查 E2E 密码是否正确
- 检查 vault 路径是否正确
- 运行 `ob sync-status` 查看详细状态

### 冲突解决
- 默认使用 merge 策略，保留两边改动
- 如需手动解决，改为 conflict 策略
