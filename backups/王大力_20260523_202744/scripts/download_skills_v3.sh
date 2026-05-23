#!/bin/bash
# 下载 superpowers-skills 仓库中的所有 skill 文件

BASE_URL="https://raw.githubusercontent.com/obra/superpowers-skills/main"
API_URL="https://api.github.com/repos/obra/superpowers-skills/contents"
OUTPUT_DIR="/root/.openclaw/workspace/superpowers-skills"

mkdir -p "$OUTPUT_DIR"

# 获取目录内容的函数
get_dir_contents() {
    local path="$1"
    curl -sL "$API_URL/$path" 2>/dev/null
}

# 下载文件的函数
download_file() {
    local path="$1"
    local output_path="$OUTPUT_DIR/$path"
    mkdir -p "$(dirname "$output_path")"
    echo -n "  下载: $path ... "
    curl -sL "$BASE_URL/$path" -o "$output_path" 2>/dev/null
    if [ -s "$output_path" ]; then
        size=$(stat -c%s "$output_path" 2>/dev/null || stat -f%z "$output_path" 2>/dev/null)
        echo "✓ (${size} bytes)"
    else
        echo "✗ 失败"
        rm -f "$output_path"
    fi
}

# 处理目录中的内容
process_directory() {
    local dir_path="$1"
    echo "处理目录: $dir_path"
    
    # 获取目录内容
    contents=$(get_dir_contents "$dir_path")
    
    # 提取每个条目的信息
    echo "$contents" | grep -E '"name"|"type"|"path"' | paste - - - | while read line; do
        name=$(echo "$line" | grep -o '"name": "[^"]*"' | head -1 | sed 's/"name": "//;s/"$//')
        type=$(echo "$line" | grep -o '"type": "[^"]*"' | head -1 | sed 's/"type": "//;s/"$//')
        path=$(echo "$line" | grep -o '"path": "[^"]*"' | head -1 | sed 's/"path": "//;s/"$//')
        
        if [ -z "$name" ] || [ "$name" = ".gitignore" ] || [ "$name" = "ABOUT.md" ]; then
            continue
        fi
        
        if [ "$type" = "file" ]; then
            download_file "$path"
        elif [ "$type" = "dir" ]; then
            # 递归处理子目录
            process_directory "$path"
        fi
    done
}

# 主目录列表
echo "开始下载 skills..."
echo ""

# 获取 skills 目录下的所有子目录
skills_dirs=$(curl -sL "$API_URL/skills" 2>/dev/null | grep -o '"name": "[^"]*"' | sed 's/"name": "//;s/"$//' | grep -v "^\.")

for dir in $skills_dirs; do
    process_directory "skills/$dir"
    echo ""
done

echo "下载完成！"
echo "文件保存在: $OUTPUT_DIR"
echo ""
echo "统计:"
find "$OUTPUT_DIR" -type f | wc -l
echo "个文件"
