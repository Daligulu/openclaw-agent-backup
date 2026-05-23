#!/bin/bash
# EvoMap配置自动修复工具 - 制度化运维神经反射弧
# 自动检测和修复配置问题

echo "🔧 EvoMap配置自动修复 - 制度化运维神经反射弧执行"
echo "===================================================="

# 加载现有配置
if [ -f "/root/.openclaw/workspace/evolver/.env" ]; then
    . /root/.openclaw/workspace/evolver/.env
fi

# 1. 检查并创建.env文件
if [ ! -f "/root/.openclaw/workspace/evolver/.env" ]; then
    echo "📝 创建.env配置文件"
    cat > /root/.openclaw/workspace/evolver/.env << EOF
# EvoMap环境配置
# 生成时间: $(date)
# 用户: 制度化运维神经反射弧架构师

# Hub服务器地址
EVOMAP_HUB_URL=https://hub.evomap.ai

# Node ID (从EvoMap账户获取)
EVOMAP_NODE_ID=node_d0cf2a3b4b3946a492a8e72e381e1198

# Node密钥 (从EvoMap账户获取，关键配置)
# A2A_NODE_SECRET=your_node_secret_here
# EVOMAP_NODE_SECRET=your_node_secret_here

# 同步配置
SYNC_INTERVAL_HOURS=24
BACKUP_ENABLED=true
EOF
    echo "✅ .env文件已创建（需要填写node_secret）"
else
    echo "✅ .env文件已存在"
fi

# 2. 检查关键配置项
echo "🔍 检查关键配置项"
missing_configs=()

if [ -z "$EVOMAP_HUB_URL" ]; then
    echo "⚠️ EVOMAP_HUB_URL未配置，使用默认值"
    echo "EVOMAP_HUB_URL=https://hub.evomap.ai" >> /root/.openclaw/workspace/evolver/.env
fi

if [ -z "$EVOMAP_NODE_ID" ]; then
    echo "⚠️ EVOMAP_NODE_ID未配置，使用默认占位符"
    echo "EVOMAP_NODE_ID=node_placeholder_$(date +%s)" >> /root/.openclaw/workspace/evolver/.env
fi

if [ -z "$A2A_NODE_SECRET" ] && [ -z "$EVOMAP_NODE_SECRET" ]; then
    echo "❌ 关键缺失: node_secret未配置"
    missing_configs+=("node_secret")
fi

# 3. 提供修复指导
echo ""
echo "📋 修复指导"
echo "=========="

if [ ${#missing_configs[@]} -eq 0 ]; then
    echo "✅ 所有关键配置项完整"
    echo "💡 建议执行验证脚本确认配置: ./evomap-config-validator.sh"
else
    echo "🔧 需要修复的配置项:"
    for item in "${missing_configs[@]}"; do
        echo "   - $item"
    done
    
    echo ""
    echo "🎯 修复步骤:"
    echo "   1. 访问 https://evomap.ai 注册账户"
    echo "   2. 在控制台获取Node ID和Node Secret"
    echo "   3. 编辑.env文件:"
    echo "      nano /root/.openclaw/workspace/evolver/.env"
    echo "   4. 更新以下配置:"
    echo "      EVOMAP_NODE_ID=您的实际Node ID"
    echo "      A2A_NODE_SECRET=您的Node Secret"
    echo "      EVOMAP_NODE_SECRET=您的Node Secret"
    echo "   5. 保存文件并重新执行验证"
fi

# 4. 生成配置修复报告
echo ""
echo "📊 配置修复报告"
echo "=============="
echo "修复时间: $(date)"
echo "用户角色: 制度化运维神经反射弧架构师"
echo "问题模式: 连续4天node_secret缺失"
echo "修复方案: 建立配置验证制度"
echo "下一步: 执行evomap-config-validator.sh验证修复效果"