#!/bin/bash
# Telegram 认证问题诊断工具
# 用于诊断和修复 Telegram bot 401 Unauthorized 错误

echo "🔍 Telegram 认证问题诊断工具"
echo "================================"
echo "当前时间: $(date)"
echo ""

# 1. 检查环境变量
echo "📋 检查 Telegram 环境变量:"
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    echo "✅ TELEGRAM_BOT_TOKEN 环境变量已设置"
    echo "    Token 长度: ${#TELEGRAM_BOT_TOKEN} 字符"
    echo "    Token 前缀: ${TELEGRAM_BOT_TOKEN:0:10}..."
else
    echo "❌ TELEGRAM_BOT_TOKEN 环境变量未设置"
fi

# 2. 检查配置文件
echo ""
echo "📁 检查 OpenClaw 配置文件:"
if [ -f "/root/.openclaw/openclaw.json" ]; then
    echo "✅ openclaw.json 配置文件存在"
    if grep -q "telegram" /root/.openclaw/openclaw.json; then
        echo "✅ 配置文件中包含 Telegram 相关配置"
    else
        echo "⚠️  配置文件中未找到 Telegram 配置"
    fi
else
    echo "❌ openclaw.json 配置文件不存在"
fi

# 3. 检查 .credentials 目录
echo ""
echo "🔐 检查凭证文件:"
CREDENTIALS_DIR="/root/.openclaw/.credentials"
if [ -d "$CREDENTIALS_DIR" ]; then
    echo "✅ .credentials 目录存在"
    TELEGRAM_FILES=$(find "$CREDENTIALS_DIR" -name "*telegram*" -o -name "*bot*token*" 2>/dev/null)
    if [ -n "$TELEGRAM_FILES" ]; then
        echo "✅ 找到 Telegram 相关凭证文件:"
        echo "$TELEGRAM_FILES" | while read file; do
            echo "   - $file"
            if [ -f "$file" ]; then
                echo "     大小: $(wc -c < "$file") 字节"
                echo "     内容预览: $(head -c 20 "$file")..."
            fi
        done
    else
        echo "❌ 未找到 Telegram 相关凭证文件"
    fi
else
    echo "❌ .credentials 目录不存在"
fi

# 4. 测试 Telegram API 连接
echo ""
echo "🌐 测试 Telegram API 连接:"
echo "正在测试 getMe API 端点..."

# 尝试从环境变量获取 token
TOKEN=""
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
    TOKEN="$TELEGRAM_BOT_TOKEN"
elif [ -f "$CREDENTIALS_DIR/telegram-bot-token.txt" ]; then
    TOKEN=$(cat "$CREDENTIALS_DIR/telegram-bot-token.txt" | tr -d '\n\r')
fi

if [ -n "$TOKEN" ]; then
    echo "使用 Token 进行 API 测试..."
    RESPONSE=$(curl -s "https://api.telegram.org/bot${TOKEN}/getMe")
    if echo "$RESPONSE" | grep -q '"ok":true'; then
        echo "✅ Telegram API 连接成功!"
        echo "   响应: $RESPONSE" | head -c 100
    else
        echo "❌ Telegram API 连接失败"
        echo "   响应: $RESPONSE"
        echo ""
        echo "可能的原因:"
        echo "1. Token 已失效或错误"
        echo "2. Bot 已被禁用"
        echo "3. 网络连接问题"
    fi
else
    echo "⚠️  未找到有效的 Telegram token，跳过 API 测试"
fi

# 5. 检查日志中的错误模式
echo ""
echo "📊 分析日志中的 Telegram 错误:"
LOG_FILE="/tmp/openclaw/openclaw-2026-04-22.log"
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "401: Unauthorized" "$LOG_FILE" 2>/dev/null || echo "0")
    echo "   发现 $ERROR_COUNT 次 401 Unauthorized 错误"
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "   最近错误时间:"
        grep "401: Unauthorized" "$LOG_FILE" | tail -1 | cut -d' ' -f1-3
    fi
    
    # 检查错误频率
    echo ""
    echo "   错误频率分析:"
    echo "   $(grep -c "telegram.*failed" "$LOG_FILE" 2>/dev/null || echo "0") 次 Telegram 失败记录"
else
    echo "❌ 日志文件不存在: $LOG_FILE"
fi

# 6. 修复建议
echo ""
echo "🔧 修复建议:"
echo "=============="
echo "1. 验证 Telegram token:"
echo "   - 访问 https://api.telegram.org/bot<YOUR_TOKEN>/getMe"
echo "   - 确保返回 {\"ok\":true,\"result\":{...}}"
echo ""
echo "2. 更新 token 文件:"
echo "   - 检查 /root/.openclaw/.credentials/telegram-bot-token.txt"
echo "   - 确保文件内容只有 token，没有多余的空格或换行"
echo ""
echo "3. 重启 OpenClaw 服务:"
echo "   openclaw gateway restart"
echo ""
echo "4. 如果 token 失效，重新创建 bot:"
echo "   - 联系 @BotFather 创建新 bot"
echo "   - 获取新 token"
echo "   - 更新配置文件"
echo ""
echo "5. 临时禁用 Telegram 插件:"
echo "   - 编辑 openclaw.json，移除 Telegram 配置"
echo "   - 重启服务避免持续错误"

# 7. 自动修复选项
echo ""
echo "⚡ 自动修复选项 (谨慎使用):"
echo "=========================="
echo "如需自动修复，请运行以下命令:"
echo ""
echo "# 1. 备份当前配置"
echo "cp /root/.openclaw/openclaw.json /root/.openclaw/openclaw.json.backup.$(date +%Y%m%d)"
echo ""
echo "# 2. 临时禁用 Telegram (如果问题持续)"
echo "jq 'del(.channels.telegram)' /root/.openclaw/openclaw.json > /tmp/openclaw-temp.json && mv /tmp/openclaw-temp.json /root/.openclaw/openclaw.json"
echo ""
echo "# 3. 重启服务"
echo "openclaw gateway restart"
echo ""
echo "✅ 诊断完成"