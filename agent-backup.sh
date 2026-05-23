#!/bin/bash
#
# OpenClaw Agent 通用备份脚本
# 适用于: OpenClaw / Hermes / Codex / Claude Code
# 版本: 1.0.0
# 作者: 王大力🐕
#

set -euo pipefail

# ==================== 配置 ====================
AGENT_NAME="${1:-王大力}"
OPENCLAW_ROOT="${OPENCLAW_ROOT:-/root/.openclaw}"
WORKSPACE="${OPENCLAW_ROOT}/workspace"
BACKUP_REPO="${BACKUP_REPO:-/tmp/openclaw-agent-backup}"
TIMESTAMP=$(TZ='Asia/Shanghai' date '+%Y%m%d_%H%M%S')
VERSION="${AGENT_NAME}_${TIMESTAMP}"
BACKUP_DIR="${BACKUP_REPO}/backups/${VERSION}"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }

# ==================== 创建备份目录 ====================
mkdir -p "${BACKUP_DIR}"/{identity,memory,skills,tools,workflows,cron,config,scripts,extensions,other}
log "备份目录: ${BACKUP_DIR}"

# ==================== 1. 身份与人格文件 (最高优先级) ====================
log "备份身份与人格文件..."
for f in SOUL.md USER.md IDENTITY.md MEMORY.md; do
    [ -f "${WORKSPACE}/${f}" ] && cp "${WORKSPACE}/${f}" "${BACKUP_DIR}/identity/" && log "  → ${f}"
done

# ==================== 2. 技能文件 ====================
log "备份技能文件..."
if [ -d "${WORKSPACE}/skills" ]; then
    # 只备份 SKILL.md 和配置文件，不备份 node_modules 等
    find "${WORKSPACE}/skills" -maxdepth 2 \( -name "SKILL.md" -o -name "_meta.json" -o -name "meta.json" -o -name "config.json" -o -name "*.yaml" -o -name "*.yml" \) | while read f; do
        rel_path="${f#${WORKSPACE}/skills/}"
        target_dir="${BACKUP_DIR}/skills/$(dirname "${rel_path}")"
        mkdir -p "${target_dir}"
        cp "${f}" "${target_dir}/"
    done
    log "  → skills/ (SKILL.md + 配置)"
fi

# 备份 OpenClaw 扩展的技能
if [ -d "${OPENCLAW_ROOT}/skills" ]; then
    find "${OPENCLAW_ROOT}/skills" -maxdepth 2 \( -name "SKILL.md" -o -name "_meta.json" -o -name "meta.json" \) | while read f; do
        rel_path="${f#${OPENCLAW_ROOT}/skills/}"
        target_dir="${BACKUP_DIR}/skills/openclaw-builtin/$(dirname "${rel_path}")"
        mkdir -p "${target_dir}"
        cp "${f}" "${target_dir}/"
    done
    log "  → openclaw/skills/ (内置技能)"
fi

# ==================== 3. 工具配置 ====================
log "备份工具配置..."
for f in TOOLS.md; do
    [ -f "${WORKSPACE}/${f}" ] && cp "${WORKSPACE}/${f}" "${BACKUP_DIR}/tools/" && log "  → ${f}"
done

# 备份凭证配置（不含实际密钥）
if [ -d "${WORKSPACE}/.credentials" ]; then
    for f in "${WORKSPACE}/.credentials/"*.env "${WORKSPACE}/.credentials/"*.sh; do
        [ -f "$f" ] && cp "$f" "${BACKUP_DIR}/tools/" && log "  → .credentials/$(basename $f)"
    done
fi

# ==================== 4. 工作流文件 ====================
log "备份工作流文件..."
if [ -d "${WORKSPACE}/workflows" ]; then
    # 备份工作流配置和模板，排除运行时数据
    find "${WORKSPACE}/workflows" -maxdepth 2 \( -name "*.md" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.py" \) | while read f; do
        rel_path="${f#${WORKSPACE}/workflows/}"
        target_dir="${BACKUP_DIR}/workflows/$(dirname "${rel_path}")"
        mkdir -p "${target_dir}"
        cp "${f}" "${target_dir}/"
    done
    log "  → workflows/"
fi

# ==================== 5. 定时任务 ====================
log "备份定时任务..."
if [ -d "${OPENCLAW_ROOT}/cron" ]; then
    cp "${OPENCLAW_ROOT}/cron/jobs.json" "${BACKUP_DIR}/cron/" 2>/dev/null && log "  → cron/jobs.json"
fi

# ==================== 6. 脚本文件 ====================
log "备份脚本文件..."
if [ -d "${WORKSPACE}/scripts" ]; then
    cp -r "${WORKSPACE}/scripts/"* "${BACKUP_DIR}/scripts/" 2>/dev/null && log "  → scripts/"
fi

# 备份工作目录下的重要脚本
for f in "${WORKSPACE}"/*.sh; do
    [ -f "$f" ] && cp "$f" "${BACKUP_DIR}/scripts/" && log "  → $(basename $f)"
done

# ==================== 7. 扩展配置 ====================
log "备份扩展配置..."
if [ -d "${OPENCLAW_ROOT}/extensions" ]; then
    for ext_dir in "${OPENCLAW_ROOT}/extensions"/*/; do
        ext_name=$(basename "${ext_dir}")
        # 只备份配置文件，不备份 node_modules
        find "${ext_dir}" -maxdepth 1 \( -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.md" \) | while read f; do
            mkdir -p "${BACKUP_DIR}/extensions/${ext_name}"
            cp "${f}" "${BACKUP_DIR}/extensions/${ext_name}/"
        done
    done
    log "  → extensions/ (配置)"
fi

# ==================== 8. 其他重要文件 ====================
log "备份其他重要文件..."
for f in AGENTS.md HEARTBEAT.md SKILL.md SKILL-TEMPLATE.md CHANGELOG.md; do
    [ -f "${WORKSPACE}/${f}" ] && cp "${WORKSPACE}/${f}" "${BACKUP_DIR}/other/" && log "  → ${f}"
done

# 备份 notes 目录
if [ -d "${WORKSPACE}/notes" ]; then
    cp -r "${WORKSPACE}/notes" "${BACKUP_DIR}/other/notes" 2>/dev/null && log "  → notes/"
fi

# 备份 state 目录
if [ -d "${WORKSPACE}/state" ]; then
    cp -r "${WORKSPACE}/state" "${BACKUP_DIR}/other/state" 2>/dev/null && log "  → state/"
fi

# ==================== 9. 生成备份清单 ====================
log "生成备份清单..."
cat > "${BACKUP_DIR}/MANIFEST.md" << EOF
# Agent 备份清单

- **Agent名称**: ${AGENT_NAME}
- **备份时间**: $(TZ='Asia/Shanghai' date '+%Y-%m-%d %H:%M:%S CST')
- **版本号**: ${VERSION}
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
EOF

# ==================== 10. 提交到 GitHub ====================
log "提交到 GitHub..."
cd "${BACKUP_REPO}"
git add -A
git commit -m "backup: ${VERSION}" --quiet
git push origin main --quiet 2>/dev/null || git push origin master --quiet
log "备份完成！"

echo ""
echo "=========================================="
echo "  备份成功！"
echo "  版本: ${VERSION}"
echo "  位置: backups/${VERSION}/"
echo "  GitHub: https://github.com/Daligulu/openclaw-agent-backup"
echo "=========================================="
