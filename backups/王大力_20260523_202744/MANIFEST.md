# Agent 备份清单

- **Agent名称**: 王大力
- **备份时间**: 2026-05-23 20:27:44 CST
- **版本号**: 王大力_20260523_202744
- **备份脚本版本**: 1.0.0

## 备份内容

### 1. 身份与人格 (identity/)
- SOUL.md - 灵魂文件，定义Agent的核心人格
- USER.md - 用户档案
- IDENTITY.md - 身份信息
- MEMORY.md - 长期记忆

### 2. 技能 (skills/)
- 各技能的 SKILL.md 和配置文件
- 不包含 node_modules 和二进制文件

### 3. 工具 (tools/)
- TOOLS.md - 工具配置说明
- .credentials/ - 凭证配置模板（不含实际密钥）

### 4. 工作流 (workflows/)
- 工作流配置、模板、脚本
- 不包含运行时生成的数据文件

### 5. 定时任务 (cron/)
- jobs.json - 所有定时任务配置

### 6. 脚本 (scripts/)
- 自动化脚本和工具

### 7. 扩展 (extensions/)
- 扩展插件的配置文件

### 8. 其他 (other/)
- AGENTS.md, HEARTBEAT.md 等辅助文件
- notes/ - 笔记
- state/ - 状态文件

## 恢复优先级

1. SOUL.md - 灵魂定义
2. USER.md - 用户上下文
3. MEMORY.md - 记忆
4. skills/ - 技能
5. TOOLS.md - 工具配置
6. extensions/ - MCP扩展
7. workflows/ - 工作流
8. cron/ - 定时任务
9. 其他文件

## 不包含的内容

- node_modules/ - 可通过 npm install 重新安装
- *.png, *.jpg, *.gif - 图片文件（可通过其他方式恢复）
- *.jsonl - 运行日志
- .venv/ - Python虚拟环境
- 大型二进制文件和缓存
