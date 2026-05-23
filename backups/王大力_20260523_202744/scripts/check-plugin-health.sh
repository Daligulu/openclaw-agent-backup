#!/bin/bash

# ============================================
# OpenClaw 插件健康检查脚本 v1.0
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
    echo "OpenClaw 插件健康检查脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -p PLUGIN   检查指定插件（如: wecom, memory-tdai）"
    echo "  -a          检查所有插件"
    echo "  -d          详细模式，显示更多信息"
    echo "  -f FILE     生成健康检查报告到指定文件"
    echo "  -h          显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 -p wecom"
    echo "  $0 -a -f /tmp/plugin-health-report.txt"
    echo "  $0"
    echo ""
}

# 检查单个插件
check_plugin() {
    local plugin_name="$1"
    local plugin_path="/root/.openclaw/extensions/$plugin_name"
    local verbose="$2"
    
    log_section "检查插件: $plugin_name"
    
    # 1. 检查插件目录是否存在
    if [[ ! -d "$plugin_path" ]]; then
        log_error "插件目录不存在: $plugin_path"
        return 1
    fi
    
    log_info "插件目录: $plugin_path"
    
    # 2. 检查package.json是否存在
    if [[ ! -f "$plugin_path/package.json" ]]; then
        log_warning "缺少package.json文件"
    else
        log_info "package.json ✓"
        
        # 提取插件信息
        local plugin_version=$(grep '"version"' "$plugin_path/package.json" | head -1 | sed 's/.*"version": "\([^"]*\)".*/\1/')
        if [[ ! -z "$plugin_version" ]]; then
            log_info "插件版本: $plugin_version"
        fi
    fi
    
    # 3. 检查依赖是否安装
    local node_modules_path="$plugin_path/node_modules"
    local pnpm_lock_path="$plugin_path/pnpm-lock.yaml"
    
    if [[ -d "$node_modules_path" ]]; then
        local node_modules_size=$(du -sh "$node_modules_path" 2>/dev/null | cut -f1)
        log_info "node_modules存在 ($node_modules_size)"
        
        # 检查package.json中的依赖是否都在node_modules中
        if [[ -f "$plugin_path/package.json" ]]; then
            local dep_count=$(grep -c '"dependencies"' "$plugin_path/package.json")
            if [[ $dep_count -gt 0 ]]; then
                log_info "检测到依赖配置"
            fi
        fi
    elif [[ -f "$pnpm_lock_path" ]]; then
        log_info "使用pnpm管理依赖 (pnpm-lock.yaml存在)"
    else
        log_warning "未找到依赖安装目录，可能需要运行 npm install"
    fi
    
    # 4. 检查index.ts/main文件是否存在
    local main_file=""
    if [[ -f "$plugin_path/index.ts" ]]; then
        main_file="index.ts"
    elif [[ -f "$plugin_path/index.js" ]]; then
        main_file="index.js"
    elif [[ -f "$plugin_path/src/index.ts" ]]; then
        main_file="src/index.ts"
    fi
    
    if [[ ! -z "$main_file" ]]; then
        log_info "入口文件: $main_file"
    else
        log_error "未找到插件入口文件 (index.ts/index.js)"
        return 1
    fi
    
    # 5. 检查插件配置文件
    local has_openclaw_config=$(find "$plugin_path" -name "openclaw.plugin.json" -type f | head -1)
    local has_clawdbot_config=$(find "$plugin_path" -name "clawdbot.plugin.json" -type f | head -1)
    
    if [[ ! -z "$has_openclaw_config" ]]; then
        log_info "OpenClaw配置文件 ✓"
    fi
    
    if [[ ! -z "$has_clawdbot_config" ]]; then
        log_info "Clawdbot配置文件 ✓"
    fi
    
    # 6. 检查技能目录
    local skills_path="$plugin_path/skills"
    if [[ -d "$skills_path" ]]; then
        local skill_count=$(find "$skills_path" -name "SKILL.md" -type f | wc -l)
        log_info "技能数量: $skill_count"
    fi
    
    # 7. 尝试编译检查（如果支持TypeScript）
    if [[ "$main_file" == *.ts ]]; then
        log_info "检测到TypeScript插件，检查编译状态..."
        if command -v tsc >/dev/null 2>&1; then
            cd "$plugin_path"
            if tsc --noEmit --skipLibCheck "$main_file" > /tmp/tsc-check.log 2>&1; then
                log_success "TypeScript编译检查通过"
            else
                log_warning "TypeScript编译可能存在问题"
                if [[ "$verbose" == "true" ]]; then
                    cat /tmp/tsc-check.log | head -5
                fi
            fi
            cd - > /dev/null
        else
            log_info "未安装TypeScript编译器 (tsc)"
        fi
    fi
    
    log_success "插件基本检查完成"
    return 0
}

# 检查所有插件
check_all_plugins() {
    local extensions_dir="/root/.openclaw/extensions"
    local verbose="$1"
    
    if [[ ! -d "$extensions_dir" ]]; then
        log_error "扩展目录不存在: $extensions_dir"
        return 1
    fi
    
    log_section "扫描扩展目录: $extensions_dir"
    
    local plugin_count=0
    local passed_count=0
    local failed_count=0
    
    for plugin_dir in "$extensions_dir"/*; do
        if [[ -d "$plugin_dir" ]]; then
            local plugin_name=$(basename "$plugin_dir")
            
            echo ""
            if check_plugin "$plugin_name" "$verbose"; then
                ((passed_count++))
            else
                ((failed_count++))
            fi
            
            ((plugin_count++))
        fi
    done
    
    echo ""
    log_header "插件健康检查总结"
    echo "  总插件数: $plugin_count"
    echo "  检查通过: $passed_count"
    echo "  检查失败: $failed_count"
    
    if [[ $failed_count -eq 0 ]]; then
        log_success "所有插件健康检查通过！"
        return 0
    else
        log_warning "有 $failed_count 个插件存在问题，建议修复"
        return 1
    fi
}

# 生成报告
generate_report() {
    local output_file="$1"
    local verbose="$2"
    
    echo "生成插件健康检查报告到: $output_file"
    
    {
        echo "# OpenClaw 插件健康检查报告"
        echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "系统: $(uname -a)"
        echo ""
        
        # 检查网关状态
        echo "## 1. OpenClaw网关状态"
        if openclaw gateway status > /tmp/gateway-status.txt 2>&1; then
            echo "网关运行正常 ✓"
            
            # 检查是否有插件加载错误
            if grep -q "failed to load" /tmp/gateway-status.txt; then
                echo "警告: 检测到插件加载错误"
                grep "failed to load" /tmp/gateway-status.txt
            fi
        else
            echo "网关状态检查失败"
        fi
        echo ""
        
        # 检查所有插件
        echo "## 2. 插件详细检查"
        echo ""
        
    } > "$output_file"
    
    # 运行检查并追加到报告
    check_all_plugins "$verbose" 2>&1 | tee -a "$output_file"
    
    log_success "报告生成完成: $output_file"
}

# 主函数
main() {
    local target_plugin=""
    local check_all="false"
    local verbose="false"
    local report_file=""
    
    # 解析参数
    while getopts "p:adf:h" opt; do
        case $opt in
            p) target_plugin="$OPTARG" ;;
            a) check_all="true" ;;
            d) verbose="true" ;;
            f) report_file="$OPTARG" ;;
            h) show_help; exit 0 ;;
            *) show_help; exit 1 ;;
        esac
    done
    
    shift $((OPTIND-1))
    
    log_header "OpenClaw 插件健康检查"
    echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    
    # 如果有报告文件，生成报告
    if [[ ! -z "$report_file" ]]; then
        generate_report "$report_file" "$verbose"
        exit $?
    fi
    
    # 执行检查
    if [[ ! -z "$target_plugin" ]]; then
        check_plugin "$target_plugin" "$verbose"
    elif [[ "$check_all" == "true" ]] || [[ $# -eq 0 ]]; then
        check_all_plugins "$verbose"
    else
        show_help
        exit 1
    fi
    
    local exit_code=$?
    
    echo ""
    log_info "检查完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 提供修复建议
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        log_section "常见问题修复建议"
        echo "  1. 缺少依赖: cd /root/.openclaw/extensions/<插件名> && npm install"
        echo "  2. 编译错误: 检查TypeScript配置和语法"
        echo "  3. 文件缺失: 确认插件目录结构完整"
        echo "  4. 重启网关: openclaw gateway restart"
    fi
    
    exit $exit_code
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi