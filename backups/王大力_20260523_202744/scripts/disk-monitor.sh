#!/bin/bash
# OpenClaw磁盘使用率监控脚本
# 自动监控磁盘使用率，超过阈值时执行安全清理并发送通知

# 配置
THRESHOLD_WARNING=80
THRESHOLD_CRITICAL=85
LOG_FILE="/root/.openclaw/workspace/logs/disk-monitor.log"
CLEANUP_HISTORY="/root/.openclaw/workspace/logs/cleanup-history.json"

# 创建日志目录
mkdir -p /root/.openclaw/workspace/logs

# 获取当前磁盘使用率
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
}

# 获取磁盘详情
get_disk_details() {
    df -h / | awk 'NR==2 {print $2, $3, $4, $5}'
}

# 安全清理操作
safe_cleanup() {
    local level=$1
    local freed_space=0
    
    echo "🔄 开始安全清理（级别: $level）"
    
    case $level in
        "warning")
            # 警告级别清理 - 轻度
            echo "  执行轻度清理..."
            npm cache clean --force 2>/dev/null || true
            # 清理7天前的/tmp文件
            find /tmp -type f -mtime +7 -delete 2>/dev/null || true
            ;;
        "critical")
            # 严重级别清理 - 中度
            echo "  执行中度清理..."
            npm cache clean --force 2>/dev/null || true
            find /tmp -type f -mtime +3 -delete 2>/dev/null || true
            sudo apt-get clean 2>/dev/null || true
            # 清理大日志文件
            find /var/log -name "*.log" -size +100M -exec truncate -s 0 {} \; 2>/dev/null || true
            ;;
    esac
    
    echo "✅ 安全清理完成"
}

# 发送通知（需要配置通知渠道）
send_notification() {
    local level=$1
    local usage=$2
    local details=$3
    
    echo "[$(date)] 磁盘使用率${level}警报: ${usage}%" >> "$LOG_FILE"
    echo "详情: $details" >> "$LOG_FILE"
    
    # 这里可以添加Telegram、邮件等通知
    # 示例: curl -X POST "https://api.telegram.org/botTOKEN/sendMessage" ...
    
    echo "📢 ${level}通知已记录"
}

# 记录清理历史
log_cleanup() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local usage_before=$1
    local usage_after=$2
    local level=$3
    
    cat >> "$CLEANUP_HISTORY" << EOF
{
  "timestamp": "$timestamp",
  "level": "$level",
  "usage_before": $usage_before,
  "usage_after": $usage_after,
  "actions": "safe_cleanup_$level"
}
EOF
}

# 生成报告
generate_report() {
    local usage=$1
    local level=$2
    
    echo ""
    echo "📊 OpenClaw磁盘监控报告"
    echo "========================="
    echo "时间: $(date)"
    echo "磁盘使用率: ${usage}%"
    echo "警报级别: $level"
    echo ""
    echo "📈 磁盘详情:"
    df -h / | head -2
    echo ""
    echo "📁 大文件分析 (前10名):"
    du -h /root/.openclaw/ 2>/dev/null | sort -rh | head -5
    echo ""
    echo "🔧 建议操作:"
    if [ "$level" = "critical" ]; then
        echo "  • 立即执行磁盘清理"
        echo "  • 检查备份文件大小"
        echo "  • 考虑升级磁盘容量"
    elif [ "$level" = "warning" ]; then
        echo "  • 监控磁盘使用率趋势"
        echo "  • 清理临时文件"
        echo "  • 优化存储策略"
    fi
    echo ""
}

# 主函数
main() {
    USAGE=$(get_disk_usage)
    DETAILS=$(get_disk_details)
    
    echo "🔍 检查磁盘使用率: ${USAGE}%"
    
    if [ $USAGE -ge $THRESHOLD_CRITICAL ]; then
        LEVEL="critical"
        echo "🚨 严重警报！磁盘使用率超过临界阈值 ($THRESHOLD_CRITICAL%)"
        
        USAGE_BEFORE=$USAGE
        safe_cleanup "critical"
        USAGE_AFTER=$(get_disk_usage)
        
        send_notification "$LEVEL" "$USAGE" "$DETAILS"
        log_cleanup "$USAGE_BEFORE" "$USAGE_AFTER" "$LEVEL"
        generate_report "$USAGE" "$LEVEL"
        
    elif [ $USAGE -ge $THRESHOLD_WARNING ]; then
        LEVEL="warning"
        echo "⚠️  警告！磁盘使用率超过警告阈值 ($THRESHOLD_WARNING%)"
        
        USAGE_BEFORE=$USAGE
        safe_cleanup "warning"
        USAGE_AFTER=$(get_disk_usage)
        
        send_notification "$LEVEL" "$USAGE" "$DETAILS"
        log_cleanup "$USAGE_BEFORE" "$USAGE_AFTER" "$LEVEL"
        generate_report "$USAGE" "$LEVEL"
        
    else
        echo "✅ 磁盘使用率正常: ${USAGE}%"
        # 日常记录
        echo "[$(date)] 磁盘使用率正常: ${USAGE}%" >> "$LOG_FILE"
    fi
    
    # 检查清理历史
    if [ -f "$CLEANUP_HISTORY" ]; then
        RECENT_CLEANUPS=$(tail -5 "$CLEANUP_HISTORY" | wc -l)
        if [ $RECENT_CLEANUPS -ge 3 ]; then
            echo "📋 注意：最近已执行多次清理操作，建议检查磁盘使用模式"
        fi
    fi
}

# 执行主函数
main "$@"
