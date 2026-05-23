#!/bin/bash
# install-trendradar.sh - TrendRadar + OpenClaw 集成安装脚本

set -e

TRENDRADAR_DIR="/opt/TrendRadar"
OPENCLAW_CONFIG="${HOME}/.openclaw/config.yaml"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================"
echo "  TrendRadar + OpenClaw 集成安装脚本"
echo "========================================"
echo ""

# 检查 Python 版本
log_info "检查 Python 版本..."
if ! command -v python3 &> /dev/null; then
    log_error "未找到 Python3，请先安装 Python 3.12+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
log_info "Python 版本: $PYTHON_VERSION"

# 检查 OpenClaw 配置目录
if [ ! -d "${HOME}/.openclaw" ]; then
    log_warn "未找到 OpenClaw 配置目录，请先安装 OpenClaw"
    exit 1
fi

# 1. 克隆项目
log_info "[1/5] 克隆 TrendRadar..."
if [ -d "$TRENDRADAR_DIR" ]; then
    log_warn "目录已存在，更新代码..."
    cd "$TRENDRADAR_DIR" && git pull
else
    sudo mkdir -p /opt
    sudo chown $(whoami):$(whoami) /opt
    git clone https://github.com/sansan0/TrendRadar.git "$TRENDRADAR_DIR"
    cd "$TRENDRADAR_DIR"
fi

# 2. 安装依赖
log_info "[2/5] 安装依赖..."
cd "$TRENDRADAR_DIR"

# 检查是否使用 uv
if command -v uv &> /dev/null; then
    log_info "使用 uv 安装依赖..."
    uv venv .venv
    source .venv/bin/activate
    uv pip install -e .
else
    log_info "使用 pip 安装依赖..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -e .
fi

# 验证安装
if python -c "import trendradar" 2>/dev/null; then
    log_info "TrendRadar 安装成功"
else
    log_error "TrendRadar 安装失败"
    exit 1
fi

# 3. 初始化配置
log_info "[3/5] 初始化配置..."
mkdir -p config/custom/keyword config/custom/ai output/news

# 创建基础关键词配置 (如果不存在)
if [ ! -f "config/frequency_words.txt" ]; then
    cat > config/frequency_words.txt << 'EOF'
[科技热点]
AI
人工智能
大模型
ChatGPT
Claude
Gemini

[社会热点]
热搜
热点
 trending

[财经热点]
股市
基金
比特币
EOF
    log_info "已创建默认关键词配置"
fi

# 4. 配置 OpenClaw
log_info "[4/5] 配置 OpenClaw..."
if [ -f "$OPENCLAW_CONFIG" ]; then
    # 备份原配置
    cp "$OPENCLAW_CONFIG" "${OPENCLAW_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
    log_info "已备份原配置"
    
    # 检查是否已存在 trendradar 配置
    if ! grep -q "trendradar:" "$OPENCLAW_CONFIG" 2>/dev/null; then
        cat >> "$OPENCLAW_CONFIG" << 'EOF'

# TrendRadar MCP Server 配置
mcp:
  servers:
    trendradar:
      command: /opt/TrendRadar/.venv/bin/python
      args:
        - "-m"
        - "mcp_server.server"
      cwd: /opt/TrendRadar
      env:
        PYTHONPATH: /opt/TrendRadar
EOF
        log_info "已添加 TrendRadar MCP 配置到 OpenClaw"
    else
        log_warn "TrendRadar MCP 配置已存在，跳过"
    fi
else
    log_warn "未找到 OpenClaw 配置文件: $OPENCLAW_CONFIG"
    log_info "请手动添加以下配置到 OpenClaw:"
    cat << 'EOF'

mcp:
  servers:
    trendradar:
      command: /opt/TrendRadar/.venv/bin/python
      args:
        - "-m"
        - "mcp_server.server"
      cwd: /opt/TrendRadar
      env:
        PYTHONPATH: /opt/TrendRadar
EOF
fi

# 5. 测试运行
log_info "[5/5] 测试运行..."
if python -m trendradar --help &> /dev/null; then
    log_info "TrendRadar CLI 测试通过"
else
    log_warn "CLI 测试失败，但安装可能仍可用"
fi

# 完成
echo ""
echo "========================================"
echo "  安装完成!"
echo "========================================"
echo ""
echo "📁 安装目录: $TRENDRADAR_DIR"
echo "⚙️  配置文件: $TRENDRADAR_DIR/config/config.yaml"
echo "🔑 关键词配置: $TRENDRADAR_DIR/config/frequency_words.txt"
echo ""
echo "🚀 下一步:"
echo "   1. 重启 OpenClaw Gateway:"
echo "      openclaw gateway restart"
echo ""
echo "   2. 测试查询 (在 OpenClaw 中):"
echo "      '今天有什么热点新闻？'"
echo ""
echo "   3. 手动运行爬虫 (可选):"
echo "      cd $TRENDRADAR_DIR"
echo "      source .venv/bin/activate"
echo "      python -m trendradar --crawl"
echo ""
echo "📖 文档: $TRENDRADAR_DIR/README.md"
echo "📖 MCP FAQ: $TRENDRADAR_DIR/README-MCP-FAQ.md"
echo ""
