#!/bin/bash
# 下载 superpowers-skills 仓库中的所有 skill 文件

BASE_URL="https://raw.githubusercontent.com/obra/superpowers-skills/main"
OUTPUT_DIR="/root/.openclaw/workspace/superpowers-skills"

mkdir -p "$OUTPUT_DIR"

# 定义所有 skill 文件 (正确的路径，包含 skills/ 前缀)
declare -a skills=(
    # Architecture
    "skills/architecture/preserving-productive-tensions/SKILL.md"
    # Collaboration
    "skills/collaboration/brainstorming/SKILL.md"
    "skills/collaboration/dispatching-parallel-agents/SKILL.md"
    "skills/collaboration/executing-plans/SKILL.md"
    "skills/collaboration/finishing-a-development-branch/SKILL.md"
    "skills/collaboration/receiving-code-review/SKILL.md"
    "skills/collaboration/remembering-conversations/SKILL.md"
    "skills/collaboration/requesting-code-review/SKILL.md"
    "skills/collaboration/subagent-driven-development/SKILL.md"
    "skills/collaboration/using-git-worktrees/SKILL.md"
    "skills/collaboration/writing-plans/SKILL.md"
    # Debugging
    "skills/debugging/defense-in-depth/SKILL.md"
    "skills/debugging/root-cause-tracing/SKILL.md"
    "skills/debugging/systematic-debugging/SKILL.md"
    "skills/debugging/verification-before-completion/SKILL.md"
    # Meta
    "skills/meta/gardening-skills-wiki/SKILL.md"
    "skills/meta/pulling-updates-from-skills-repository/SKILL.md"
    "skills/meta/sharing-skills/SKILL.md"
    "skills/meta/testing-skills-with-subagents/SKILL.md"
    "skills/meta/writing-skills/SKILL.md"
    # Problem-solving
    "skills/problem-solving/collision-zone-thinking/SKILL.md"
    "skills/problem-solving/inversion-exercise/SKILL.md"
    "skills/problem-solving/meta-pattern-recognition/SKILL.md"
    "skills/problem-solving/scale-game/SKILL.md"
    "skills/problem-solving/simplification-cascades/SKILL.md"
    "skills/problem-solving/when-stuck/SKILL.md"
    # Research
    "skills/research/tracing-knowledge-lineages/SKILL.md"
    # Testing
    "skills/testing/condition-based-waiting/SKILL.md"
    "skills/testing/test-driven-development/SKILL.md"
    "skills/testing/testing-anti-patterns/SKILL.md"
    # Using-skills
    "skills/using-skills/find-skills/SKILL.md"
    "skills/using-skills/skill-run/SKILL.md"
)

# 下载所有 skill 文件
echo "开始下载 skills..."
for path in "${skills[@]}"; do
    output_path="$OUTPUT_DIR/$path"
    mkdir -p "$(dirname "$output_path")"
    echo -n "下载: $path ... "
    curl -sL "$BASE_URL/$path" -o "$output_path" 2>/dev/null
    if [ -s "$output_path" ]; then
        size=$(stat -c%s "$output_path" 2>/dev/null || stat -f%z "$output_path" 2>/dev/null)
        echo "✓ (${size} bytes)"
    else
        echo "✗ 失败或为空"
        rm -f "$output_path"
    fi
done

echo ""
echo "下载完成！"
echo "文件保存在: $OUTPUT_DIR"
echo ""
echo "统计:"
find "$OUTPUT_DIR" -name "SKILL.md" | wc -l
echo "个 skill 文件"
