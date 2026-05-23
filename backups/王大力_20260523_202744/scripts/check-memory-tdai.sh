#!/bin/bash

echo "=== 检查 memory-tdai 插件 ==="
echo ""

MEMORY_TDAI_DIR="/root/.openclaw/extensions/memory-tdai"

if [ -d "$MEMORY_TDAI_DIR" ]; then
    echo "✅ memory-tdai 目录存在"
    cd "$MEMORY_TDAI_DIR"
    
    if [ -d "node_modules" ]; then
        echo "✅ node_modules 目录存在"
        
        if [ -d "node_modules/sqlite-vec" ]; then
            echo "✅ sqlite-vec 依赖存在"
            echo "✅ memory-tdai 插件依赖完整"
        else
            echo "❌ sqlite-vec 依赖缺失"
            echo ""
            echo "尝试安装 sqlite-vec..."
            npm install sqlite-vec --save --no-audit --no-fund 2>&1 | tail -10
        fi
    else
        echo "❌ node_modules 目录不存在"
        echo ""
        echo "尝试安装所有依赖..."
        npm install --no-audit --no-fund 2>&1 | tail -10
    fi
else
    echo "❌ memory-tdai 目录不存在"
fi

echo ""
echo "检查完成"