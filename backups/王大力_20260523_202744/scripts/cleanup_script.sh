#!/bin/bash
# OpenClaw 系统清理脚本
# 安全清理临时文件和建议优化操作

echo "🔧 OpenClaw 系统清理工具"
echo "============================="
echo "当前时间: $(date)"
echo ""

# 1. 检查磁盘使用情况
echo "📊 磁盘使用情况:"
df -h /

# 2. 清理旧日志文件（安全操作）
echo ""
echo "🧹 清理7天前的旧日志文件..."
find /tmp/openclaw -name "openclaw-*.log" -mtime +7 -delete 2>/dev/null
echo "日志清理完成"

# 3. 清理 JITI 缓存文件（安全操作）
echo ""
echo "🗑️  清理旧的 JITI 缓存文件..."
find /tmp/jiti -name "*openclaw*" -type f -mtime +1 -delete 2>/dev/null
echo "JITI 缓存清理完成"

# 4. 检查 OpenClaw 目录大小
echo ""
echo "📁 OpenClaw 目录分析:"
du -sh /root/.openclaw/ 2>/dev/null || echo "目录不存在"
echo ""

# 5. 显示扩展目录中的大文件
echo "🔍 扩展目录中的大文件 (>50MB):"
find /root/.openclaw/extensions -type f -size +50M -exec ls -lh {} \; 2>/dev/null | head -5

# 6. 建议操作（需要用户确认）
echo ""
echo "🚨 建议操作（需要用户确认后执行）:"
echo "--------------------------------"
echo "1. 清理 npm 缓存: npm cache clean --force"
echo "2. 检查 wecom 插件依赖: cd /root/.openclaw/extensions/wecom && npm ls --depth=0"
echo "3. 重新安装缺失依赖: npm install dingtalk-stream zod sqlite-vec"
echo "4. 验证 Telegram token: 检查 .credentials/telegram-bot-token.txt 文件"
echo ""
echo "⚠️  注意: 上述建议操作可能影响系统稳定性，请在测试环境中验证后执行"
echo ""
echo "✅ 脚本执行完成"