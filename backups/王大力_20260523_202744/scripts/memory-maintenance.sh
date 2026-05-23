#!/bin/bash
# 每日记忆整理脚本
# 执行时间: $(date '+%Y-%m-%d %H:%M:%S')

echo "=== 每日记忆整理开始 ==="
echo "执行时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. 检查记忆目录
echo "1. 检查记忆目录状态..."
MEMORY_DIR="/root/.openclaw/workspace/memory"
if [ -d "$MEMORY_DIR" ]; then
    FILE_COUNT=$(ls -1 "$MEMORY_DIR"/*.md 2>/dev/null | wc -l)
    TOTAL_SIZE=$(du -sh "$MEMORY_DIR" | cut -f1)
    echo "   ✓ 记忆目录存在"
    echo "   - 文件数量: $FILE_COUNT"
    echo "   - 总大小: $TOTAL_SIZE"
else
    echo "   ✗ 记忆目录不存在: $MEMORY_DIR"
fi
echo ""

# 2. 检查 MEMORY.md 主文件
echo "2. 检查 MEMORY.md 主文件..."
MAIN_MEMORY="/root/.openclaw/workspace/MEMORY.md"
if [ -f "$MAIN_MEMORY" ]; then
    LAST_MODIFIED=$(stat -c %y "$MAIN_MEMORY" 2>/dev/null || stat -f %Sm "$MAIN_MEMORY" 2>/dev/null)
    FILE_SIZE=$(du -h "$MAIN_MEMORY" | cut -f1)
    echo "   ✓ MEMORY.md 存在"
    echo "   - 最后修改: $LAST_MODIFIED"
    echo "   - 文件大小: $FILE_SIZE"
else
    echo "   ✗ MEMORY.md 不存在"
fi
echo ""

# 3. 统计最近7天的记忆文件
echo "3. 最近7天的记忆文件..."
RECENT_FILES=$(find "$MEMORY_DIR" -name "*.md" -mtime -7 2>/dev/null | sort)
if [ -n "$RECENT_FILES" ]; then
    echo "$RECENT_FILES" | while read file; do
        filename=$(basename "$file")
        filesize=$(du -h "$file" | cut -f1)
        echo "   - $filename ($filesize)"
    done
else
    echo "   无最近7天的记忆文件"
fi
echo ""

# 4. 检查文件系统状态
echo "4. 文件系统状态..."
DISK_USAGE=$(df -h /root/.openclaw/workspace | tail -1)
echo "   磁盘使用情况: $DISK_USAGE"
echo ""

echo "=== 每日记忆整理完成 ==="
