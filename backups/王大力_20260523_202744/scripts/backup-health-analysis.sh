#!/bin/bash

echo "🔍 OpenClaw 备份健康度分析报告"
echo "====================================="
echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 1. 检查最近的备份文件
echo "📊 备份文件分析"
echo "--------------"
backup_files=$(find /tmp -name "openclaw-backup-*.tar.gz" -type f -mtime -7 2>/dev/null | sort | tail -10)

if [ -z "$backup_files" ]; then
    echo "❌ 未找到备份文件"
    exit 1
fi

echo "最近10个备份文件:"
count=1
for file in $backup_files; do
    filename=$(basename "$file")
    size=$(du -h "$file" 2>/dev/null | cut -f1)
    mtime=$(stat -c %y "$file" 2>/dev/null | cut -c1-19)
    echo "  $count. $filename ($size, 修改: $mtime)"
    count=$((count+1))
done
echo ""

# 2. 分析备份大小趋势
echo "📈 备份大小趋势"
echo "--------------"
sizes=()
for file in $backup_files; do
    size_kb=$(du -k "$file" 2>/dev/null | cut -f1)
    sizes+=("$size_kb")
done

# 计算变化
echo "备份文件数量: ${#sizes[@]} 个"
if [ ${#sizes[@]} -ge 2 ]; then
    first_size=${sizes[0]}
    last_size=${sizes[-1]}
    growth=$((last_size - first_size))
    growth_percent=$((growth * 100 / first_size))
    
    echo "最早备份: ${first_size}KB (~$((first_size/1024))MB)"
    echo "最新备份: ${last_size}KB (~$((last_size/1024))MB)"
    echo "增长量: ${growth}KB (~$((growth/1024))MB, +${growth_percent}%)"
    
    if [ $growth_percent -gt 10 ]; then
        echo "⚠️ 警告: 备份增长较快 (+${growth_percent}%)，建议检查文件变化"
    else
        echo "✓ 备份增长正常 (+${growth_percent}%)"
    fi
fi
echo ""

# 3. 检查备份完整性
echo "🔧 备份完整性检查"
echo "--------------"
latest_backup=$(find /tmp -name "openclaw-backup-*.tar.gz" -type f -mtime -1 2>/dev/null | sort | tail -1)

if [ -n "$latest_backup" ]; then
    echo "检查最新备份: $(basename "$latest_backup")"
    
    # 检查tar文件是否可读
    if tar -tzf "$latest_backup" > /dev/null 2>&1; then
        echo "✓ 备份文件结构完整"
        file_count=$(tar -tzf "$latest_backup" | wc -l)
        echo "  包含文件数: $file_count"
    else
        echo "❌ 备份文件可能损坏"
    fi
else
    echo "⚠️ 未找到24小时内的备份文件"
fi
echo ""

# 4. 磁盘使用情况
echo "💾 磁盘使用情况"
echo "--------------"
df_output=$(df -h /dev/vda2 | tail -1)
total=$(echo "$df_output" | awk '{print $2}')
used=$(echo "$df_output" | awk '{print $3}')
avail=$(echo "$df_output" | awk '{print $4}')
use_percent=$(echo "$df_output" | awk '{print $5}' | tr -d '%')

echo "磁盘: /dev/vda2"
echo "总容量: $total"
echo "已使用: $used"
echo "可用空间: $avail"
echo "使用率: ${use_percent}%"

if [ $use_percent -gt 85 ]; then
    echo "⚠️ 警告: 磁盘使用率超过85%，建议清理"
elif [ $use_percent -gt 75 ]; then
    echo "📝 提示: 磁盘使用率较高，建议监控"
else
    echo "✓ 磁盘使用情况正常"
fi
echo ""

# 5. 备份节律检查
echo "⏰ 备份节律检查"
echo "--------------"
echo "最近备份时间统计:"
for file in $backup_files; do
    filename=$(basename "$file")
    # 从文件名提取时间
    date_part=$(echo "$filename" | sed 's/openclaw-backup-//' | sed 's/.tar.gz//')
    echo_date=$(echo "$date_part" | sed 's/_/ /')
    echo "  - $echo_date"
done

echo ""
echo "📋 建议:"
echo "1. 监控备份增长趋势，确保不会过快增长"
echo "2. 定期验证备份文件完整性"
echo "3. 保持磁盘使用率在85%以下"
echo "4. 确保12小时备份节律稳定执行"