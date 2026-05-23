# OpenClaw Agent 通用备份仓库

## 📋 概述

本仓库用于存储 OpenClaw Agent 的完整备份，支持跨平台迁移和恢复。

**兼容平台**: OpenClaw / Hermes / Codex / Claude Code

## 🗂️ 备份结构

```
backups/
└── Agent名称_YYYYMMDD_HHMMSS/
    ├── MANIFEST.md          # 备份清单
    ├── identity/            # 身份与人格文件
    │   ├── SOUL.md          # 灵魂定义（最高优先级）
    │   ├── USER.md          # 用户档案
    │   ├── IDENTITY.md      # 身份信息
    │   └── MEMORY.md        # 长期记忆
    ├── skills/              # 技能配置
    │   └── skill-name/
    │       ├── SKILL.md
    │       └── _meta.json
    ├── tools/               # 工具配置
    │   ├── TOOLS.md
    │   └── *.env            # 凭证模板
    ├── workflows/           # 工作流
    │   └── workflow-name/
    ├── cron/                # 定时任务
    │   └── jobs.json
    ├── scripts/             # 脚本文件
    ├── extensions/          # 扩展配置
    └── other/               # 其他文件
        ├── AGENTS.md
        ├── HEARTBEAT.md
        ├── notes/
        └── state/
```

## 🔄 恢复优先级

按以下顺序恢复，确保Agent功能完整：

| 优先级 | 文件/目录 | 说明 |
|--------|-----------|------|
| 1 | `SOUL.md` | 灵魂定义，决定Agent核心人格 |
| 2 | `USER.md` | 用户上下文，个性化服务基础 |
| 3 | `MEMORY.md` | 长期记忆，历史经验积累 |
| 4 | `skills/` | 技能库，Agent能力来源 |
| 5 | `TOOLS.md` | 工具配置，环境变量说明 |
| 6 | `extensions/` | MCP扩展，外部工具集成 |
| 7 | `workflows/` | 工作流，自动化流程 |
| 8 | `cron/` | 定时任务，自动化调度 |
| 9 | `other/` | 其他辅助文件 |

## 🚀 快速恢复指南

### OpenClaw 平台

```bash
# 1. 克隆仓库
git clone https://github.com/Daligulu/openclaw-agent-backup.git
cd openclaw-agent-backup

# 2. 选择要恢复的版本
VERSION="Agent名称_YYYYMMDD_HHMMSS"

# 3. 恢复身份文件
cp backups/${VERSION}/identity/SOUL.md ~/.openclaw/workspace/
cp backups/${VERSION}/identity/USER.md ~/.openclaw/workspace/
cp backups/${VERSION}/identity/IDENTITY.md ~/.openclaw/workspace/
cp backups/${VERSION}/identity/MEMORY.md ~/.openclaw/workspace/

# 4. 恢复技能（需要手动安装依赖）
cp -r backups/${VERSION}/skills/* ~/.openclaw/workspace/skills/
# 对每个技能执行: cd skills/xxx && npm install

# 5. 恢复工具配置
cp backups/${VERSION}/tools/TOOLS.md ~/.openclaw/workspace/

# 6. 恢复工作流
cp -r backups/${VERSION}/workflows/* ~/.openclaw/workspace/workflows/

# 7. 恢复定时任务
cp backups/${VERSION}/cron/jobs.json ~/.openclaw/cron/

# 8. 重启 Gateway
openclaw gateway restart
```

### Hermes 平台

```bash
# 1. 恢复身份文件到 Hermes workspace
cp identity/SOUL.md ~/.hermes/workspace/
cp identity/USER.md ~/.hermes/workspace/
cp identity/MEMORY.md ~/.hermes/workspace/

# 2. 恢复技能配置
cp -r skills/* ~/.hermes/workspace/skills/

# 3. 恢复工作流
cp -r workflows/* ~/.hermes/workspace/workflows/

# 4. 重启 Hermes
hermes restart
```

### Codex / Claude Code 平台

```bash
# 1. 复制核心文件到项目根目录
cp identity/SOUL.md ./
cp identity/USER.md ./
cp identity/MEMORY.md ./

# 2. 复制技能到 skills 目录
cp -r skills/* ./skills/

# 3. 复制工作流
cp -r workflows/* ./workflows/

# 4. 根据 TOOLS.md 配置环境变量
```

## 📝 备份内容说明

### ✅ 已备份

- **身份文件**: SOUL.md, USER.md, IDENTITY.md, MEMORY.md
- **技能配置**: 所有技能的 SKILL.md 和配置文件
- **工具配置**: TOOLS.md 和凭证模板
- **工作流**: 工作流配置、模板、脚本
- **定时任务**: jobs.json 中的所有任务配置
- **脚本**: 自动化脚本和工具
- **扩展**: 扩展插件的配置文件
- **笔记**: notes/ 目录下的笔记文件
- **状态**: state/ 目录下的状态文件

### ❌ 不备份

- **node_modules/** - 可通过 `npm install` 重新安装
- **图片文件** (*.png, *.jpg, *.gif) - 文件过大，通过其他方式恢复
- **运行日志** (*.jsonl) - 历史记录，非必要
- **虚拟环境** (.venv/) - 可重新创建
- **缓存文件** - 可重新生成
- **二进制大文件** - 超过 10MB 的文件

## 🛠️ 手动触发备份

```bash
# 备份当前 Agent（默认名称：王大力）
bash agent-backup.sh

# 备份指定名称的 Agent
bash agent-backup.sh "我的Agent名称"
```

## ⏰ 定时备份

可以通过 OpenClaw Cron 设置定时备份：

```bash
# 每天凌晨 3 点备份
openclaw cron add \
  --name "Agent每日备份" \
  --schedule "0 3 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "执行 Agent 备份脚本: bash /path/to/agent-backup.sh '王大力'" \
  --to "feishu:user:ou_xxx"
```

## 🔐 安全说明

- 凭证文件只备份模板，不包含实际密钥
- 建议将仓库设为私有（当前为公开，便于演示）
- 敏感信息应通过环境变量配置，不要硬编码

## 📊 版本命名规则

```
Agent名称_YYYYMMDD_HHMMSS
```

- **Agent名称**: 自定义的Agent名称
- **YYYYMMDD**: 备份日期（北京时间）
- **HHMMSS**: 备份时间（北京时间）

示例：`王大力_20260523_202500`

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License
