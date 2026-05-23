#!/bin/bash

# ============================================
# 磁盘空间紧急清理脚本 v1.0
# 作者：王大力🐕 (AI助手)
# 创建时间：2026-04-21
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_header() {
    echo -e "${CYAN}$1${NC}"
}

log_section() {
    echo -e "${BLUE}==>${NC} $1"
}

log_info() {
    echo -e "  ${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "  ${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "  ${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "  ${RED}[ERROR]${NC} $1"
}

# 显示帮助
show_help() {
    echo "磁盘空间紧急清理脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --safe      仅执行安全检查，不实际删除"
    echo "  --dry-run   模拟运行，显示将要执行的操作"
    echo "  --backup N  保留最近N个备份文件（默认：3）"
    echo "  --logs N    保留最近N天的日志（默认：30）"
    echo "  --all       执行所有清理操作"
    echo "  -h, --help  显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 --safe           # 安全检查模式"
    echo "  $0 --dry-run        # 模拟运行"
    echo "  $0 --backup 3       # 清理备份文件（保留3个）"
    echo "  $0 --all            # 执行所有清理"
    echo ""
}

# 检查磁盘空间
check_disk_space() {
    log_section "检查磁盘空间"
    
    local current_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    local available=$(df -h / | tail -1 | awk '{print $4}')
    
    log_info "根分区使用率: ${current_usage}%"
    log_info "可用空间: $available"
    
    if [[ $current_usage -ge 90 ]]; then
        log_error "紧急: 磁盘使用率超过90%！"
        return 1
    elif [[ $current_usage -ge 85 ]]; then
        log_warning "警告: 磁盘使用率超过85%"
        return 2
    elif [[ $current_usage -ge 80 ]]; then
        log_warning "注意: 磁盘使用率超过80%"
        return 3
    else
        log_success "磁盘空间正常"
        return 0
    fi
}

# 清理备份文件
cleanup_backups() {
    local keep_count="$1"
    local dry_run="$2"
    local safe_mode="$3"
    
    log_section "清理备份文件"
    log_info "保留最近 $keep_count 个备份文件"
    
    local backup_files=($(ls -t /tmp/openclaw-backup-*.tar.gz 2>/dev/null))
    local total_files=${#backup_files[@]}
    
    if [[ $total_files -eq 0 ]]; then
        log_info "未找到备份文件"
        return 0
    fi
    
    log_info "当前备份文件数: $total_files"
    
    if [[ $total_files -le $keep_count ]]; then
        log_info "备份文件数量正常，无需清理"
        return 0
    fi
    
    local files_to_remove=${#backup_files[@]}
    ((files_to_remove-=keep_count))
    
    log_info "计划删除 $files_to_remove 个旧备份文件"
    
    for ((i=keep_count; i<total_files; i++)); do
        local file="${backup_files[$i]}"
        local file_size=$(du -h "$file" | cut -f1)
        
        if [[ "$dry_run" == "true" ]]; then
            log_info "[模拟] 删除: $(basename "$file") ($file_size)"
        elif [[ "$safe_mode" == "true" ]]; then
            log_info "[安全模式] 跳过删除: $(basename "$file") ($file_size)"
        else
            log_info "删除: $(basename "$file") ($file_size)"
            rm -f "$file"
        fi
    done
    
    if [[ "$dry_run" != "true" && "$safe_mode" != "true" ]]; then
        log_success "备份文件清理完成"
    fi
    
    return 0
}

# 清理系统日志
cleanup_system_logs() {
    local keep_days="$1"
    local dry_run="$2"
    local safe_mode="$3"
    
    log_section "清理系统日志"
    log_info "保留最近 $keep_days 天的日志"
    
    # 检查/var/log目录大小
    local log_dir_size=$(du -sh /var/log 2>/dev/null | cut -f1)
    log_info "日志目录大小: $log_dir_size"
    
    # 查找大日志文件
    local large_logs=$(find /var/log -type f -size +100M 2>/dev/null | head -5)
    
    if [[ ! -z "$large_logs" ]]; then
        log_warning "发现大日志文件:"
        for log in $large_logs; do
            local size=$(du -h "$log" | cut -f1)
            log_info "  $log ($size)"
        done
    fi
    
    # 清理旧日志文件
    if [[ "$dry_run" == "true" ]]; then
        log_info "[模拟] 将删除30天前的日志文件"
    elif [[ "$safe_mode" == "true" ]]; then
        log_info "[安全模式] 将检查30天前的日志文件"
    else
        log_info "删除30天前的日志文件..."
        find /var/log -type f -mtime +$keep_days -delete 2>/dev/null || true
        log_success "系统日志清理完成"
    fi
    
    return 0
}

# 清理包管理器缓存
cleanup_package_cache() {
    local dry_run="$2"
    local safe_mode="$3"
    
    log_section "清理包管理器缓存"
    
    # npm缓存
    if command -v npm >/dev/null 2>&1; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "[模拟] 清理npm缓存"
        elif [[ "$safe_mode" == "true" ]]; then
            log_info "[安全模式] 跳过npm缓存清理"
        else
            log_info "清理npm缓存..."
            npm cache clean --force > /dev/null 2>&1 || true
        fi
    fi
    
    # pnpm缓存
    if command -v pnpm >/dev/null 2>&1; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "[模拟] 清理pnpm缓存"
        elif [[ "$safe_mode" == "true" ]]; then
            log_info "[安全模式] 跳过pnpm缓存清理"
        else
            log_info "清理pnpm缓存..."
            pnpm store prune > /dev/null 2>&1 || true
        fi
    fi
    
    # apt缓存
    if command -v apt-get >/dev/null 2>&1; then
        if [[ "$dry_run" == "true" ]]; then
            log_info "[模拟] 清理apt缓存"
        elif [[ "$safe_mode" == "true" ]]; then
            log_info "[安全模式] 跳过apt缓存清理"
        else
            log_info "清理apt缓存..."
            apt-get clean > /dev/null 2>&1 || true
            apt-get autoclean > /dev/null 2>&1 || true
        fi
    fi
    
    if [[ "$dry_run" != "true" && "$safe_mode" != "true" ]]; then
        log_success "包管理器缓存清理完成"
    fi
    
    return 0
}

# 生成清理报告
generate_cleanup_report() {
    log_section "磁盘空间清理报告"
    
    local before_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    local before_available=$(df -h / | tail -1 | awk '{print $4}')
    
    echo "清理前状态:"
    echo "  使用率: ${before_usage}%"
    echo "  可用空间: $before_available"
    echo ""
    
    # 执行清理（根据参数）
    
    echo "清理后状态:"
    local after_usage=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    local after_available=$(df -h / | tail -1 | awk '{print $4}')
    
    echo "  使用率: ${after_usage}%"
    echo "  可用空间: $after_available"
    echo ""
    
    local space_freed=$((100 - after_usage - (100 - before_usage)))
    if [[ $space_freed -gt 0 ]]; then
        log_success "释放空间: 约${space_freed}%"
    else
        log_info "空间使用率无变化"
    fi
}

# 主函数
main() {
    local safe_mode="false"
    local dry_run="false"
    local cleanup_all="false"
    local keep_backups=3
    local keep_logs=30
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --safe)
                safe_mode="true"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            --backup)
                keep_backups="$2"
                shift 2
                ;;
            --logs)
                keep_logs="$2"
                shift 2
                ;;
            --all)
                cleanup_all="true"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log_header "磁盘空间紧急清理"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # 检查磁盘空间状态
    check_disk_space
    local disk_status=$?
    
    if [[ $disk_status -eq 0 ]]; then
        log_info "磁盘空间正常，无需紧急清理"
        exit 0
    fi
    
    echo ""
    log_section "开始执行清理操作"
    
    # 执行清理
    if [[ "$cleanup_all" == "true" ]] || [[ "$dry_run" == "true" ]]; then
        cleanup_backups "$keep_backups" "$dry_run" "$safe_mode"
        cleanup_system_logs "$keep_logs" "$dry_run" "$safe_mode"
        cleanup_package_cache "$dry_run" "$safe_mode"
    else
        # 默认只清理备份文件（最安全有效）
        cleanup_backups "$keep_backups" "$dry_run" "$safe_mode"
    fi
    
    echo ""
    generate_cleanup_report
    
    # 最终检查
    echo ""
    check_disk_space
    
    echo ""
    log_info "清理完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 提供后续建议
    if [[ $disk_status -ge 2 ]]; then
        echo ""
        log_section "后续建议"
        echo "  1. 监控磁盘使用率变化"
        echo "  2. 考虑优化备份策略（压缩算法、增量备份）"
        echo "  3. 设置磁盘使用率告警（85%/90%/95%）"
        echo "  4. 定期运行此清理脚本"
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi