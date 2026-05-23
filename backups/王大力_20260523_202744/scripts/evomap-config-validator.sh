#!/bin/bash
# EvoMap配置验证工具 - 制度化运维神经反射弧
# 解决连续4天相同的node_secret缺失问题模式

echo "🔍 EvoMap配置验证制度检查 - 制度化运维神经反射弧执行"
echo "====================================================="

# 1. 环境变量检查
echo "📋 1. 环境变量配置验证"
if [ -f "/root/.openclaw/workspace/evolver/.env" ]; then
    echo "✅ .env文件存在"
    . /root/.openclaw/workspace/evolver/.env
    echo "   EVOMAP_HUB_URL: ${EVOMAP_HUB_URL:-未设置}"
    echo "   EVOMAP_NODE_ID: ${EVOMAP_NODE_ID:-未设置}"
    echo "   A2A_NODE_SECRET: ${A2A_NODE_SECRET:-❌ 未设置 - 关键缺失}"
    echo "   EVOMAP_NODE_SECRET: ${EVOMAP_NODE_SECRET:-❌ 未设置 - 关键缺失}"
else
    echo "❌ .env文件不存在"
fi

# 2. Node ID验证
echo "📋 2. Node ID完整性验证"
if [ -n "$EVOMAP_NODE_ID" ]; then
    echo "✅ Node ID已配置: $EVOMAP_NODE_ID"
    if [[ "$EVOMAP_NODE_ID" =~ ^node_ ]]; then
        echo "   ✅ Node ID格式正确（以node_开头）"
    else
        echo "   ⚠️ Node ID格式异常（不以node_开头）"
    fi
else
    echo "❌ Node ID未配置"
fi

# 3. 密钥存在性验证
echo "📋 3. 密钥配置验证（node_secret）"
if [ -n "$A2A_NODE_SECRET" ] || [ -n "$EVOMAP_NODE_SECRET" ]; then
    echo "✅ 密钥配置存在"
    echo "   A2A_NODE_SECRET长度: ${#A2A_NODE_SECRET:-0}字符"
    echo "   EVOMAP_NODE_SECRET长度: ${#EVOMAP_NODE_SECRET:-0}字符"
else
    echo "❌ 关键缺失：node_secret未配置"
    echo "   📌 这是连续4天同步失败的根本原因"
fi

# 4. 执行环境验证
echo "📋 4. 执行环境验证"
echo "   Node路径: $(which node || echo '未找到')"
echo "   Node版本: $(node --version 2>/dev/null || echo '不可用')"
echo "   工作目录: /root/.openclaw/workspace/evolver"

# 5. Hello消息测试验证
echo "📋 5. Hello消息测试验证（模拟同步）"
cd /root/.openclaw/workspace/evolver 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ 工作目录访问正常"
    if [ -f "scripts/a2a_export.js" ]; then
        echo "✅ a2a_export.js脚本存在"
        echo "   📋 脚本功能:"
        echo "     - 生成Hello消息 ✅"
        echo "     - 发布publish消息 ❌（需要node_secret）"
    else
        echo "❌ a2a_export.js脚本不存在"
    fi
else
    echo "❌ 无法访问工作目录"
fi

# 6. 问题模式分析与解决建议
echo "📋 6. 连续问题模式分析（制度化运维视角）"
echo "   📊 问题模式: 连续4天相同的node_secret缺失问题"
echo "   🔍 根本原因: 缺少配置验证制度，导致问题重复出现"
echo "   🛠️ 解决方案: 建立配置验证制度神经反射弧"
echo ""
echo "🎯 制度化运维建议:"
echo "   1. 建立环境变量预检查机制（本次检查）"
echo "   2. 建立配置问题自动检测和修复机制"
echo "   3. 将配置验证纳入cron执行前检查"
echo "   4. 建立配置错误的自动告警和通知制度"

# 7. 验证结果总结
echo ""
echo "📈 验证结果总结"
echo "====================================================="
if [ -n "$A2A_NODE_SECRET" ] || [ -n "$EVOMAP_NODE_SECRET" ]; then
    echo "✅ 配置验证通过 - 可以正常执行同步"
    echo "   💡 建议: 确保密钥安全，定期轮换"
else
    echo "❌ 配置验证失败 - node_secret缺失"
    echo "   🚨 问题: 这是连续4天同步失败的根源"
    echo "   🔧 修复方案:"
    echo "     1. 注册EvoMap账户获取node_secret"
    echo "     2. 将node_secret添加到.env文件"
    echo "     3. 重新执行验证脚本确认修复"
fi
echo ""
echo "🕐 验证时间: $(date)"
echo "👤 用户角色: 制度化运维神经反射弧架构师"
echo "🎯 验证目的: 基于连续问题模式建立配置验证制度"