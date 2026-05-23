#!/bin/bash

# ============================================
# OpenClaw 备份验证脚本 v1.0
# 作者：王大力🐕 (AI助手)
# 创建时间：2026-04-21
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助
show_help() {
    echo "OpenClaw 备份验证脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f FILE    验证指定的备份文件"
    echo "  -d DIR     验证目录中的所有备份文件"
    echo "  -l N       验证最近N个备份文件（默认：3）"
    echo "  -v         详细模式，显示更多信息"
    echo "  -h         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -f /tmp/openclaw-backup-20260421_125505.tar.gz"
    echo "  $0 -d /tmp -l 5"
    echo "  $0 -l 3"
    echo ""
}

# 验证单个备份文件
validate_backup_file() {
    local backup_file="$1"
    local verbose="$2"
    
    if [[ ! -f "$backup_file" ]]; then
        log_error "备份文件不存在: $backup_file"
        return 1
    fi
    
    log_info "正在验证备份文件: $(basename "$backup_file")"
    
    # 检查文件大小
    local file_size=$(stat -c%s "$backup_file")
    local file_size_mb=$((file_size / 1024 / 1024))
    
    if [[ "$verbose" == "true" ]]; then
        log_info "文件大小: ${file_size_mb}MB"
    fi
    
    # 验证tar.gz格式完整性
    if ! tar -tzf "$backup_file" > /dev/null 2>&1; then
        log_error "备份文件格式损坏或非标准tar.gz格式"
        return 1
    fi
    
    # 提取文件列表（不实际解压）
    local file_count=$(tar -tzf "$backup_file" | wc -l)
    
    # 检查关键目录是否存在
    local has_workspace=$(tar -tzf "$backup_file" | grep -c "^\.openclaw/workspace")
    local has_memory=$(tar -tzf "$backup_file" | grep -c "^\.openclaw/memory")
    local has_extensions=$(tar -tzf "$backup_file" | grep -c "^\.openclaw/extensions")
    
    if [[ "$verbose" == "true" ]]; then
        log_info "压缩包内文件总数: $file_count"
        log_info "包含workspace目录: $([[ $has_workspace -gt 0 ]] && echo "是" || echo "否")"
        log_info "包含memory目录: $([[ $has_memory -gt 0 ]] && echo "是" || echo "否")"
        log_info "包含extensions目录: $([[ $has_extensions -gt 0 ]] && echo "是" || echo "否")"
    fi
    
    # 检查关键文件
    local critical_missing=""
    if [[ $has_workspace -eq 0 ]]; then
        critical_missing="${critical_missing}workspace目录 "
    fi
    
    if [[ ! -z "$critical_missing" ]]; then
        log_warning "备份缺少关键目录: $critical_missing"
    fi
    
    # 计算压缩比（估计）
    if [[ "$verbose" == "true" ]]; then
        local extracted_size=$(tar -tzf "$backup_file" --totals 2>/dev/null | grep "total bytes" | awk '{print $3}' | tail -1)
        if [[ ! -z "$extracted_size" && $extracted_size -gt 0 ]]; then
            local compression_ratio=$(echo "scale=2; $file_size * 100 / $extracted_size" | bc)
            log_info "压缩率: ${compression_ratio}%"
        fi
    fi
    
    log_success "备份验证通过: $(basename "$backup_file")"
    echo "  文件大小: ${file_size_mb}MB"
    echo "  文件数量: $file_count"
    echo "  关键目录: ✅"
    
    return 0
}

# 验证目录中的备份文件
validate_backup_directory() {
    local backup_dir="$1"
    local limit="$2"
    local verbose="$3"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "目录不存在: $backup_dir"
        return 1
    fi
    
    # 查找备份文件，按修改时间排序
    local backup_files=($(find "$backup_dir" -name "openclaw-backup-*.tar.gz" -type f | sort -r | head -n "$limit"))
    
    if [[ ${#backup_files[@]} -eq 0 ]]; then
        log_error "在目录 $backup_dir 中未找到备份文件"
        return 1
    fi
    
    log_info "找到 ${#backup_files[@]} 个备份文件，验证最近 $limit 个"
    
    local passed=0
    local failed=0
    
    for backup_file in "${backup_files[@]}"; do
        echo ""
        echo "========================================"
        if validate_backup_file "$backup_file" "$verbose"; then
            ((passed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    echo "========================================"
    log_info "验证完成: 通过 $passed / 失败 $failed"
    
    if [[ $failed -eq 0 ]]; then
        log_success "所有备份文件验证成功！"
    else
        log_warning "有 $failed 个备份文件验证失败"
        return 1
    fi
}

# 验证最近的备份文件
validate_recent_backups() {
    local limit="$1"
    local verbose="$2"
    
    log_info "验证最近 $limit 个备份文件"
    validate_backup_directory "/tmp" "$limit" "$verbose"
}

# 主函数
main() {
    local target_file=""
    local target_dir=""
    local limit=3
    local verbose="false"
    
    # 解析参数
    while getopts "f:d:l:vh" opt; do
        case $opt in
            f) target_file="$OPTARG" ;;
            d) target_dir="$OPTARG" ;;
            l) limit="$OPTARG" ;;
            v) verbose="true" ;;
            h) show_help; exit 0 ;;
            *) show_help; exit 1 ;;
        esac
    done
    
    shift $((OPTIND-1))
    
    echo "========================================"
    echo "OpenClaw 备份验证脚本 v1.0"
    echo "========================================"
    
    # 执行验证
    if [[ ! -z "$target_file" ]]; then
        validate_backup_file "$target_file" "$verbose"
    elif [[ ! -z "$target_dir" ]]; then
        validate_backup_directory "$target_dir" "$limit" "$verbose"
    else
        validate_recent_backups "$limit" "$verbose"
    fi
    
    echo ""
    log_info "验证完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi