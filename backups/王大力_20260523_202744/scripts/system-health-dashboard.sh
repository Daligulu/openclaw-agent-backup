#!/bin/bash

# ============================================
# OpenClaw 系统健康监控仪表板 v1.0
# 作者：王大力🐕 (AI助手)
# 创建时间：2026-04-22
# ============================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
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
    echo "OpenClaw 系统健康监控仪表板"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --refresh SEC  自动刷新间隔（秒）"
    echo "  --compact      紧凑模式显示"
    echo "  --detail       详细模式显示"
    echo "  --report FILE  生成HTML报告到文件"
    echo "  -h, --help     显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0               # 标准检查"
    echo "  $0 --refresh 30  # 每30秒刷新"
    echo "  $0 --detail      # 详细模式"
    echo ""
}

# 获取系统信息
get_system_info() {
    echo "获取系统信息..."
    
    local uptime_info=$(uptime)
    local load_average=$(echo "$uptime_info" | grep -o "load average:.*")
    local current_time=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "系统时间: $current_time"
    echo "运行时间: $uptime_info"
    echo "负载情况: $load_average"
    
    # CPU信息
    local cpu_count=$(nproc)
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "CPU核心数: $cpu_count"
    echo "CPU使用率: ${cpu_usage}%"
    
    # 内存信息
    local mem_info=$(free -h | grep Mem)
    local total_mem=$(echo "$mem_info" | awk '{print $2}')
    local used_mem=$(echo "$mem_info" | awk '{print $3}')
    local free_mem=$(echo "$mem_info" | awk '{print $4}')
    echo "内存总量: $total_mem"
    echo "已用内存: $used_mem"
    echo "空闲内存: $free_mem"
}

# 检查磁盘空间
check_disk_space() {
    echo "检查磁盘空间..."
    
    local disk_info=$(df -h /)
    local usage_percent=$(echo "$disk_info" | tail -1 | awk '{print $5}' | sed 's/%//')
    local available=$(echo "$disk_info" | tail -1 | awk '{print $4}')
    local total=$(echo "$disk_info" | tail -1 | awk '{print $2}')
    local used=$(echo "$disk_info" | tail -1 | awk '{print $3}')
    
    echo "根分区: $total (已用: $used, 可用: $available)"
    echo "使用率: ${usage_percent}%"
    
    if [[ $usage_percent -ge 90 ]]; then
        log_error "紧急: 磁盘使用率超过90%！"
        return 1
    elif [[ $usage_percent -ge 85 ]]; then
        log_warning "警告: 磁盘使用率超过85%"
        return 2
    elif [[ $usage_percent -ge 80 ]]; then
        log_warning "注意: 磁盘使用率超过80%"
        return 3
    else
        log_success "磁盘空间正常"
        return 0
    fi
}

# 检查OpenClaw网关状态
check_openclaw_gateway() {
    echo "检查OpenClaw网关状态..."
    
    if ! command -v openclaw >/dev/null 2>&1; then
        log_error "OpenClaw CLI未安装"
        return 1
    fi
    
    local gateway_status=$(openclaw gateway status 2>&1)
    
    # 检查是否运行
    if echo "$gateway_status" | grep -q "Runtime: running"; then
        log_success "网关服务运行正常"
        
        # 检查插件加载
        local plugin_errors=$(echo "$gateway_status" | grep -c "failed to load")
        if [[ $plugin_errors -eq 0 ]]; then
            log_success "所有插件加载正常"
        else
            log_warning "检测到 $plugin_errors 个插件加载问题"
        fi
        
        # 检查服务配置
        local config_warnings=$(echo "$gateway_status" | grep -c "Service config issue")
        if [[ $config_warnings -gt 0 ]]; then
            log_warning "服务配置需要优化"
        fi
        
        return 0
    else
        log_error "网关服务未运行"
        return 1
    fi
}

# 检查备份系统状态
check_backup_system() {
    echo "检查备份系统状态..."
    
    # 查找备份文件
    local backup_files=($(ls -t /tmp/openclaw-backup-*.tar.gz 2>/dev/null))
    local total_backups=${#backup_files[@]}
    
    if [[ $total_backups -eq 0 ]]; then
        log_warning "未找到备份文件"
        return 2
    fi
    
    echo "备份文件数量: $total_backups"
    
    # 显示最近的备份
    local latest_backup="${backup_files[0]}"
    local latest_size=$(du -h "$latest_backup" | cut -f1)
    local latest_time=$(stat -c %y "$latest_backup" | cut -d' ' -f1-2)
    
    echo "最新备份: $(basename "$latest_backup")"
    echo "备份大小: $latest_size"
    echo "备份时间: $latest_time"
    
    # 检查备份频率
    if [[ $total_backups -ge 2 ]]; then
        local second_latest="${backup_files[1]}"
        local second_time=$(stat -c %y "$second_latest" | cut -d' ' -f1-2)
        
        local time_diff=$(( $(date -d "$latest_time" +%s) - $(date -d "$second_time" +%s) ))
        local hours_diff=$((time_diff / 3600))
        
        echo "备份间隔: ${hours_diff}小时"
        
        if [[ $hours_diff -le 24 ]]; then
            log_success "备份频率正常（24小时内）"
        else
            log_warning "备份间隔较长（超过24小时）"
        fi
    fi
    
    return 0
}

# 检查网络连接
check_network_connectivity() {
    echo "检查网络连接..."
    
    # 检查互联网连接
    if ping -c 2 8.8.8.8 >/dev/null 2>&1; then
        log_success "互联网连接正常"
    else
        log_error "互联网连接失败"
        return 1
    fi
    
    # 检查DNS解析
    if nslookup google.com >/dev/null 2>&1; then
        log_success "DNS解析正常"
    else
        log_warning "DNS解析可能有问题"
    fi
    
    return 0
}

# 检查插件健康状况
check_plugin_health() {
    echo "检查插件健康状况..."
    
    local extensions_dir="/root/.openclaw/extensions"
    local plugin_count=0
    local healthy_count=0
    
    if [[ ! -d "$extensions_dir" ]]; then
        log_warning "扩展目录不存在"
        return 2
    fi
    
    for plugin_dir in "$extensions_dir"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            
            # 基本检查
            if [[ -f "$plugin_dir/package.json" ]] && [[ -f "$plugin_dir/index.ts" || -f "$plugin_dir/index.js" ]]; then
                ((healthy_count++))
            fi
            
            ((plugin_count++))
        fi
    done
    
    echo "插件总数: $plugin_count"
    echo "健康插件: $healthy_count"
    
    if [[ $plugin_count -eq $healthy_count ]]; then
        log_success "所有插件基本健康"
        return 0
    else
        log_warning "有插件可能存在配置问题"
        return 3
    fi
}

# 生成健康报告
generate_health_report() {
    local report_file="$1"
    
    echo "生成系统健康报告到: $report_file"
    
    {
        echo "<!DOCTYPE html>"
        echo "<html lang='zh-CN'>"
        echo "<head>"
        echo "    <meta charset='UTF-8'>"
        echo "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        echo "    <title>OpenClaw 系统健康报告 - $(date '+%Y-%m-%d %H:%M:%S')</title>"
        echo "    <style>"
        echo "        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }"
        echo "        .container { max-width: 1200px; margin: 0 auto; }"
        echo "        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 20px; }"
        echo "        .card { background: white; border-radius: 8px; padding: 20px; margin-bottom: 15px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }"
        echo "        .status-good { color: #10b981; font-weight: bold; }"
        echo "        .status-warning { color: #f59e0b; font-weight: bold; }"
        echo "        .status-error { color: #ef4444; font-weight: bold; }"
        echo "        .metric { display: flex; justify-content: space-between; margin: 10px 0; }"
        echo "        .metric-name { font-weight: 500; }"
        echo "        .metric-value { font-weight: 600; }"
        echo "        .progress-bar { height: 8px; background: #e5e7eb; border-radius: 4px; margin: 5px 0; overflow: hidden; }"
        echo "        .progress-fill { height: 100%; border-radius: 4px; }"
        echo "        .progress-good { background: #10b981; }"
        echo "        .progress-warning { background: #f59e0b; }"
        echo "        .progress-error { background: #ef4444; }"
        echo "        table { width: 100%; border-collapse: collapse; margin: 10px 0; }"
        echo "        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #e5e7eb; }"
        echo "        th { background: #f9fafb; font-weight: 600; }"
        echo "    </style>"
        echo "</head>"
        echo "<body>"
        echo "    <div class='container'>"
        echo "        <div class='header'>"
        echo "            <h1>🐕 OpenClaw 系统健康监控报告</h1>"
        echo "            <p>生成时间: $(date '+%Y-%m-%d %H:%M:%S') | 分析师: 王大力</p>"
        echo "        </div>"
        
        # 系统概览
        echo "        <div class='card'>"
        echo "            <h2>📊 系统概览</h2>"
        echo "            <div class='metric'>"
        echo "                <span class='metric-name'>运行时间</span>"
        echo "                <span class='metric-value'>$(uptime -p | sed 's/up //')</span>"
        echo "            </div>"
        echo "            <div class='metric'>"
        echo "                <span class='metric-name'>系统负载</span>"
        echo "                <span class='metric-value'>$(uptime | grep -o 'load average:.*')</span>"
        echo "            </div>"
        echo "        </div>"
        
        # 磁盘空间
        local disk_info=$(df -h / | tail -1)
        local usage_percent=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
        local status_class="status-good"
        local progress_class="progress-good"
        
        if [[ $usage_percent -ge 85 ]]; then
            status_class="status-error"
            progress_class="progress-error"
        elif [[ $usage_percent -ge 80 ]]; then
            status_class="status-warning"
            progress_class="progress-warning"
        fi
        
        echo "        <div class='card'>"
        echo "            <h2>💾 磁盘空间</h2>"
        echo "            <div class='metric'>"
        echo "                <span class='metric-name'>根分区使用率</span>"
        echo "                <span class='metric-value $status_class'>${usage_percent}%</span>"
        echo "            </div>"
        echo "            <div class='progress-bar'>"
        echo "                <div class='progress-fill $progress_class' style='width: ${usage_percent}%'></div>"
        echo "            </div>"
        echo "            <p><strong>容量:</strong> $(echo "$disk_info" | awk '{print $2}') | <strong>已用:</strong> $(echo "$disk_info" | awk '{print $3}') | <strong>可用:</strong> $(echo "$disk_info" | awk '{print $4}')</p>"
        echo "        </div>"
        
        # 内存状态
        local mem_info=$(free -h | grep Mem)
        echo "        <div class='card'>"
        echo "            <h2>🧠 内存状态</h2>"
        echo "            <p><strong>总量:</strong> $(echo "$mem_info" | awk '{print $2}') | <strong>已用:</strong> $(echo "$mem_info" | awk '{print $3}') | <strong>空闲:</strong> $(echo "$mem_info" | awk '{print $4}')</p>"
        echo "        </div>"
        
        # 备份状态
        local backup_files=($(ls -t /tmp/openclaw-backup-*.tar.gz 2>/dev/null))
        local total_backups=${#backup_files[@]}
        
        echo "        <div class='card'>"
        echo "            <h2>📦 备份系统状态</h2>"
        echo "            <p><strong>备份数量:</strong> $total_backups</p>"
        
        if [[ $total_backups -gt 0 ]]; then
            echo "            <table>"
            echo "                <tr><th>备份文件</th><th>大小</th><th>修改时间</th></tr>"
            
            for ((i=0; i<$total_backups && i<5; i++)); do
                local backup="${backup_files[$i]}"
                local size=$(du -h "$backup" | cut -f1)
                local time=$(stat -c %y "$backup" | cut -d' ' -f1-2)
                echo "                <tr>"
                echo "                    <td>$(basename "$backup")</td>"
                echo "                    <td>$size</td>"
                echo "                    <td>$time</td>"
                echo "                </tr>"
            done
            
            echo "            </table>"
        fi
        echo "        </div>"
        
        # 插件状态
        local extensions_dir="/root/.openclaw/extensions"
        local plugin_count=0
        local healthy_count=0
        
        if [[ -d "$extensions_dir" ]]; then
            for plugin_dir in "$extensions_dir"/*; do
                if [[ -d "$plugin_dir" ]]; then
                    ((plugin_count++))
                    if [[ -f "$plugin_dir/package.json" ]]; then
                        ((healthy_count++))
                    fi
                fi
            done
        fi
        
        echo "        <div class='card'>"
        echo "            <h2>🔌 插件状态</h2>"
        echo "            <p><strong>插件总数:</strong> $plugin_count</p>"
        echo "            <p><strong>健康插件:</strong> $healthy_count</p>"
        
        if [[ $plugin_count -eq $healthy_count ]]; then
            echo "            <p class='status-good'>✅ 所有插件配置正常</p>"
        else
            echo "            <p class='status-warning'>⚠️ 有插件可能存在配置问题</p>"
        fi
        echo "        </div>"
        
        # 检查时间
        echo "        <div class='card'>"
        echo "            <h2>⏰ 检查信息</h2>"
        echo "            <p><strong>检查时间:</strong> $(date '+%Y-%m-%d %H:%M:%S')</p>"
        echo "            <p><strong>脚本版本:</strong> 系统健康监控仪表板 v1.0</p>"
        echo "            <p><strong>运行主机:</strong> $(hostname)</p>"
        echo "        </div>"
        
        echo "    </div>"
        echo "</body>"
        echo "</html>"
    } > "$report_file"
    
    log_success "HTML健康报告已生成: $report_file"
}

# 主函数
main() {
    local refresh_interval=0
    local compact_mode="false"
    local detail_mode="false"
    local report_file=""
    
    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --refresh)
                refresh_interval="$2"
                shift 2
                ;;
            --compact)
                compact_mode="true"
                shift
                ;;
            --detail)
                detail_mode="true"
                shift
                ;;
            --report)
                report_file="$2"
                shift 2
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
    
    # 生成报告
    if [[ ! -z "$report_file" ]]; then
        generate_health_report "$report_file"
        exit $?
    fi
    
    # 主循环
    while true; do
        clear
        log_header "🐕 OpenClaw 系统健康监控仪表板"
        echo "更新时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # 系统概览
        if [[ "$compact_mode" == "false" ]]; then
            get_system_info
            echo ""
        fi
        
        # 关键指标检查
        echo "🔍 关键系统指标检查"
        echo "----------------------------------------"
        
        # 磁盘空间
        check_disk_space
        echo ""
        
        # OpenClaw网关
        check_openclaw_gateway
        echo ""
        
        # 备份系统
        check_backup_system
        echo ""
        
        # 网络连接
        if [[ "$detail_mode" == "true" ]]; then
            check_network_connectivity
            echo ""
        fi
        
        # 插件健康
        if [[ "$detail_mode" == "true" ]]; then
            check_plugin_health
            echo ""
        fi
        
        # 退出条件
        if [[ $refresh_interval -eq 0 ]]; then
            break
        fi
        
        echo "下次刷新: $refresh_interval 秒后..."
        sleep "$refresh_interval"
    done
    
    echo ""
    log_info "检查完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
}

# 脚本入口
if [[ "${BASH_RUNNING_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi