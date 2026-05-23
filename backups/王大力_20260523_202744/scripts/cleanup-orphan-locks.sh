#!/bin/bash
# cleanup-orphan-locks.sh
# 清理 OpenClaw 孤儿 session lock 文件
# 孤儿 lock = lock 文件存在但 sessions.json 中无对应 sessionId
# 用法: ./cleanup-orphan-locks.sh [--dry-run]

SESSIONS_DIR="/root/.openclaw/agents/main/sessions"
SESSIONS_JSON="$SESSIONS_DIR/sessions.json"
DRY_RUN=false
LOG_FILE="/tmp/openclaw-orphan-lock-cleanup.log"

if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
    echo "[DRY RUN] 仅检查，不删除"
fi

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 获取注册表中的所有 sessionId
get_registered_session_ids() {
    if [ -f "$SESSIONS_JSON" ]; then
        python3 -c "
import sys, json
try:
    d = json.load(open('$SESSIONS_JSON'))
    for k, v in d.items():
        sid = v.get('sessionId', '')
        if sid:
            print(sid)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
" 2>/dev/null
    fi
}

# 检查所有 lock 文件
orphan_count=0
total_locks=0

for lockfile in "$SESSIONS_DIR"/*.jsonl.lock; do
    [ -f "$lockfile" ] || continue
    total_locks=$((total_locks + 1))
    
    # 提取 session ID (去掉 .jsonl.lock 后缀)
    basename=$(basename "$lockfile")
    session_id="${basename%.jsonl.lock}"
    
    # 检查 sessionId 是否在注册表中
    registered=$(get_registered_session_ids | grep -c "^${session_id}$" 2>/dev/null)
    
    if [ "$registered" -eq 0 ]; then
        orphan_count=$((orphan_count + 1))
        log "发现孤儿 lock: $session_id (无对应 session 注册)"
        
        if [ "$DRY_RUN" = false ]; then
            rm -f "$lockfile"
            log "已删除: $lockfile"
        fi
    else
        log "正常 lock: $session_id"
    fi
done

if [ $orphan_count -eq 0 ]; then
    log "检查完成: $total_locks 个 lock 文件，无孤儿"
else
    log "清理完成: 发现 $orphan_count 个孤儿 lock，已处理"
fi
