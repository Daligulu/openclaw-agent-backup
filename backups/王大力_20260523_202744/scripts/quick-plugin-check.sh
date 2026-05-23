#!/bin/bash

echo "=== 快速插件依赖检查 ==="
echo "检查时间: $(date)"
echo ""

EXTENSIONS_DIR="/root/.openclaw/extensions"

echo "扩展目录: $EXTENSIONS_DIR"
echo ""

# 检查目录是否存在
if [ ! -d "$EXTENSIONS_DIR" ]; then
    echo "错误: 扩展目录不存在"
    exit 1
fi

echo "扫描插件依赖问题:"
echo "-----------------"

# 检查 ddingtalk 插件
echo "1. ddingtalk 插件:"
if [ -d "$EXTENSIONS_DIR/ddingtalk" ]; then
    echo "   ✓ 目录存在"
    
    # 检查 package.json
    if [ -f "$EXTENSIONS_DIR/ddingtalk/package.json" ]; then
        echo "   ✓ package.json 存在"
    else
        echo "   ✗ package.json 不存在"
    fi
    
    # 检查 node_modules
    if [ -d "$EXTENSIONS_DIR/ddingtalk/node_modules" ]; then
        echo "   ✓ node_modules 目录存在"
        
        # 检查特定依赖
        if [ -d "$EXTENSIONS_DIR/ddingtalk/node_modules/zod" ]; then
            echo "   ✓ zod 依赖存在"
        else
            echo "   ✗ zod 依赖缺失 (日志中发现: Error: Cannot find module 'zod')"
        fi
        
        if [ -d "$EXTENSIONS_DIR/ddingtalk/node_modules/dingtalk-stream" ]; then
            echo "   ✓ dingtalk-stream 依赖存在"
        else
            echo "   ✗ dingtalk-stream 依赖缺失 (日志中发现: Error: Cannot find module 'dingtalk-stream')"
        fi
    else
        echo "   ✗ node_modules 目录不存在"
    fi
else
    echo "   ✗ 目录不存在"
fi

echo ""

# 检查 memory-tdai 插件
echo "2. memory-tdai 插件:"
if [ -d "$EXTENSIONS_DIR/memory-tdai" ]; then
    echo "   ✓ 目录存在"
    
    # 检查 package.json
    if [ -f "$EXTENSIONS_DIR/memory-tdai/package.json" ]; then
        echo "   ✓ package.json 存在"
    else
        echo "   ✗ package.json 不存在"
    fi
    
    # 检查 node_modules
    if [ -d "$EXTENSIONS_DIR/memory-tdai/node_modules" ]; then
        echo "   ✓ node_modules 目录存在"
        
        # 检查特定依赖
        if [ -d "$EXTENSIONS_DIR/memory-tdai/node_modules/sqlite-vec" ]; then
            echo "   ✓ sqlite-vec 依赖存在"
        else
            echo "   ✗ sqlite-vec 依赖缺失 (日志中发现: Failed to load sqlite-vec extension)"
        fi
    else
        echo "   ✗ node_modules 目录不存在"
    fi
else
    echo "   ✗ 目录不存在"
fi

echo ""

# 检查 wecom 插件
echo "3. wecom 插件:"
if [ -d "$EXTENSIONS_DIR/wecom" ]; then
    echo "   ✓ 目录存在"
    
    # 检查 package.json
    if [ -f "$EXTENSIONS_DIR/wecom/package.json" ]; then
        echo "   ✓ package.json 存在"
    else
        echo "   ✗ package.json 不存在"
    fi
    
    # 检查 node_modules
    if [ -d "$EXTENSIONS_DIR/wecom/node_modules" ]; then
        echo "   ✓ node_modules 目录存在"
        echo "   ℹ 依赖状态检查完成"
    else
        echo "   ✗ node_modules 目录不存在"
    fi
else
    echo "   ✗ 目录不存在"
fi

echo ""
echo "=== 检查完成 ==="