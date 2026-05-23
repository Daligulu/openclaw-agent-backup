#!/bin/bash

# ============================================
# ddingtalk 插件快速修复工具
# 制度化运维神经反射弧架构师 - 紧急修复工具
# 创建时间: 2026-04-29
# ============================================

set -e

echo "🔧 ddingtalk 插件快速修复工具"
echo "================================"
echo "开始时间: $(date)"
echo ""

DDINGTALK_DIR="/root/.openclaw/extensions/ddingtalk"

# 检查目录
if [ ! -d "$DDINGTALK_DIR" ]; then
    echo "❌ 错误: ddingtalk 插件目录不存在: $DDINGTALK_DIR"
    exit 1
fi

echo "✅ ddingtalk 插件目录存在"
cd "$DDINGTALK_DIR"

# 检查 package.json
if [ ! -f "package.json" ]; then
    echo "❌ 错误: package.json 不存在"
    exit 1
fi

echo "✅ package.json 存在"

# 检查当前依赖状态
echo ""
echo "📋 当前依赖状态检查:"
echo "-------------------"

if [ -d "node_modules" ]; then
    echo "✅ node_modules 目录存在"
    
    # 检查特定依赖
    if [ -d "node_modules/zod" ]; then
        echo "✅ zod 依赖存在"
    else
        echo "❌ zod 依赖缺失 (日志错误: Cannot find module 'zod')"
    fi
    
    if [ -d "node_modules/dingtalk-stream" ]; then
        echo "✅ dingtalk-stream 依赖存在"
    else
        echo "❌ dingtalk-stream 依赖缺失 (日志错误: Cannot find module 'dingtalk-stream')"
    fi
else
    echo "❌ node_modules 目录不存在"
fi

echo ""
echo "🔄 开始修复依赖..."
echo "-----------------"

# 安装缺失依赖
echo "1. 安装 zod..."
if npm install zod --save --no-audit --no-fund 2>&1 | grep -q "added"; then
    echo "   ✅ zod 安装成功"
else
    echo "   ⚠️  zod 安装可能有问题，检查输出"
fi

echo ""
echo "2. 安装 dingtalk-stream..."
if npm install dingtalk-stream --save --no-audit --no-fund 2>&1 | grep -q "added"; then
    echo "   ✅ dingtalk-stream 安装成功"
else
    echo "   ⚠️  dingtalk-stream 安装可能有问题，检查输出"
fi

echo ""
echo "✅ 依赖安装完成"
echo ""
echo "📊 修复后验证:"
echo "-------------"

if [ -d "node_modules/zod" ]; then
    echo "✅ zod 依赖验证通过"
else
    echo "❌ zod 依赖验证失败"
fi

if [ -d "node_modules/dingtalk-stream" ]; then
    echo "✅ dingtalk-stream 依赖验证通过"
else
    echo "❌ dingtalk-stream 依赖验证失败"
fi

echo ""
echo "🚀 建议下一步操作:"
echo "1. 重启 OpenClaw Gateway:"
echo "   openclaw gateway restart"
echo ""
echo "2. 检查插件加载日志:"
echo "   tail -f /tmp/openclaw/openclaw-*.log | grep -i ddingtalk"
echo ""
echo "3. 验证插件功能:"
echo "   等待 Gateway 重启后，检查 ddingtalk 插件是否正常加载"

echo ""
echo "================================"
echo "完成时间: $(date)"
echo "制度化运维神经反射弧架构师工具包"