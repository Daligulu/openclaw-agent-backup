#!/bin/bash
# OpenClaw 备份脚本 v2.0
# 自动备份OpenClaw配置到GitHub仓库

set -e

# 配置
BACKUP_DIR="/tmp"
OPENCLAW_DIR="/root/.openclaw"
WORKSPACE_DIR="$OPENCLAW_DIR/workspace"
LOG_FILE="/var/log/openclaw-backup.log"
GITHUB_REPO="https://github.com/Daligulu/openclaw-lulu"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"  # 从环境变量获取
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="openclaw-backup-${DATE}"
BACKUP_FILE="${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 创建备份目录
mkdir -p "$BACKUP_DIR"

log "=========================================="
log "OpenClaw备份开始: $DATE"
log "=========================================="

# 检查OpenClaw目录
if [ ! -d "$OPENCLAW_DIR" ]; then
    log "错误: OpenClaw目录不存在: $OPENCLAW_DIR"
    exit 1
fi

# 计算上次备份大小（用于比较）
LAST_BACKUP=$(ls -t ${BACKUP_DIR}/openclaw-backup-*.tar.gz 2>/dev/null | head -1)
if [ -n "$LAST_BACKUP" ]; then
    LAST_SIZE=$(du -h "$LAST_BACKUP" 2>/dev/null | cut -f1)
    LAST_TIME=$(stat -c %y "$LAST_BACKUP" 2>/dev/null | cut -d' ' -f1)
    log "上次备份: $LAST_BACKUP (大小: $LAST_SIZE, 时间: $LAST_TIME)"
else
    log "这是首次备份"
fi

# 创建临时备份目录
TEMP_DIR=$(mktemp -d)
log "创建临时目录: $TEMP_DIR"

# 复制文件（使用科学的排除策略）
log "开始复制文件..."
rsync -av --progress \
    --exclude='node_modules' \
    --exclude='.cache' \
    --exclude='tmp' \
    --exclude='*.log' \
    --exclude='.git' \
    --exclude='*.tar.gz' \
    --max-size=10m \
    "$OPENCLAW_DIR/" "$TEMP_DIR/openclaw/" 2>&1 | tee -a "$LOG_FILE" || true

# 创建备份包
log "创建压缩包: $BACKUP_FILE"
tar -czf "$BACKUP_FILE" -C "$TEMP_DIR" openclaw/ 2>&1 | tee -a "$LOG_FILE"

# 计算备份大小
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log "备份完成，大小: $BACKUP_SIZE"

# 生成差异报告
log "生成差异报告..."
REPORT_FILE="${TEMP_DIR}/backup-report.txt"
cat > "$REPORT_FILE" << EOF
OpenClaw备份报告
================
备份时间: $(date '+%Y-%m-%d %H:%M:%S %Z')
备份文件: $BACKUP_NAME.tar.gz
备份大小: $BACKUP_SIZE

文件统计:
EOF

# 统计文件数量
FILE_COUNT=$(find "$TEMP_DIR/openclaw" -type f 2>/dev/null | wc -l)
DIR_COUNT=$(find "$TEMP_DIR/openclaw" -type d 2>/dev/null | wc -l)
echo "  - 文件数: $FILE_COUNT" >> "$REPORT_FILE"
echo "  - 目录数: $DIR_COUNT" >> "$REPORT_FILE"

# 检查关键文件
echo "" >> "$REPORT_FILE"
echo "关键文件状态:" >> "$REPORT_FILE"
for file in "workspace/SOUL.md" "workspace/USER.md" "workspace/IDENTITY.md" "workspace/MEMORY.md" "workspace/AGENTS.md"; do
    if [ -f "$TEMP_DIR/openclaw/$file" ]; then
        MOD_TIME=$(stat -c %y "$TEMP_DIR/openclaw/$file" | cut -d' ' -f1)
        echo "  ✓ $file (修改: $MOD_TIME)" >> "$REPORT_FILE"
    else
        echo "  ✗ $file (缺失)" >> "$REPORT_FILE"
    fi
done

# 最近24小时修改的配置文件
echo "" >> "$REPORT_FILE"
echo "最近24小时修改的配置文件:" >> "$REPORT_FILE"
find "$TEMP_DIR/openclaw" -name "*.json" -o -name "*.md" -o -name "*.js" -o -name "*.ts" -o -name "*.sh" 2>/dev/null | \
    xargs stat -c '%Y %n' 2>/dev/null | \
    awk -v cutoff=$(($(date +%s) - 86400)) '$1 > cutoff {print $2}' | \
    head -10 >> "$REPORT_FILE" || echo "  无" >> "$REPORT_FILE"

# 大小变化比较
if [ -n "$LAST_BACKUP" ]; then
    LAST_SIZE_BYTES=$(du -b "$LAST_BACKUP" | cut -f1)
    CURR_SIZE_BYTES=$(du -b "$BACKUP_FILE" | cut -f1)
    SIZE_DIFF=$((CURR_SIZE_BYTES - LAST_SIZE_BYTES))
    if [ $SIZE_DIFF -gt 0 ]; then
        SIZE_PCT=$(awk "BEGIN {printf \"%.1f\", ($SIZE_DIFF/$LAST_SIZE_BYTES)*100}")
        echo "" >> "$REPORT_FILE"
        echo "大小变化: +$SIZE_DIFF bytes (+$SIZE_PCT%)" >> "$REPORT_FILE"
    elif [ $SIZE_DIFF -lt 0 ]; then
        SIZE_PCT=$(awk "BEGIN {printf \"%.1f\", ($SIZE_DIFF/$LAST_SIZE_BYTES)*100}")
        echo "" >> "$REPORT_FILE"
        echo "大小变化: $SIZE_DIFF bytes ($SIZE_PCT%)" >> "$REPORT_FILE"
    else
        echo "" >> "$REPORT_FILE"
        echo "大小变化: 无变化" >> "$REPORT_FILE"
    fi
fi

cat "$REPORT_FILE" | tee -a "$LOG_FILE"

# 尝试推送到GitHub
if [ -n "$GITHUB_TOKEN" ]; then
    log "尝试推送到GitHub..."
    cd "$TEMP_DIR"
    git init 2>/dev/null || true
    git config user.email "backup@openclaw.local" 2>/dev/null || true
    git config user.name "OpenClaw Backup" 2>/dev/null || true
    git add . 2>/dev/null || true
    git commit -m "Backup $DATE" 2>/dev/null || true
    
    # 推送逻辑（如果配置了远程仓库）
    if git remote get-url origin 2>/dev/null; then
        git push origin main 2>&1 | tee -a "$LOG_FILE" || log "GitHub推送失败"
    else
        log "未配置GitHub远程仓库，跳过推送"
    fi
else
    log "未设置GITHUB_TOKEN，跳过GitHub推送"
fi

# 清理临时目录
rm -rf "$TEMP_DIR"
log "清理临时目录完成"

# 保留最近10个备份，删除旧的
log "清理旧备份文件..."
ls -t ${BACKUP_DIR}/openclaw-backup-*.tar.gz 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null || true
REMAINING=$(ls ${BACKUP_DIR}/openclaw-backup-*.tar.gz 2>/dev/null | wc -l)
log "保留备份数量: $REMAINING"

log "=========================================="
log "OpenClaw备份完成: $BACKUP_NAME.tar.gz ($BACKUP_SIZE)"
log "备份文件位置: $BACKUP_FILE"
log "=========================================="

# 输出报告内容用于Telegram推送
echo ""
echo "=== BACKUP_REPORT_START ==="
cat "$REPORT_FILE"
echo "=== BACKUP_REPORT_END ==="

exit 0
