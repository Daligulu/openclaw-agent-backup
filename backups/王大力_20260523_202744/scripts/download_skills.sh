#!/bin/bash
# 下载 superpowers-skills 仓库中的所有 skill 文件

BASE_URL="https://raw.githubusercontent.com/obra/superpowers-skills/main"
OUTPUT_DIR="/root/.openclaw/workspace/superpowers-skills"

mkdir -p "$OUTPUT_DIR"

# 定义所有 skill 文件
declare -A skills
declare -A skill_dirs

# Architecture
skill_dirs["architecture"]="architecture"
skills["architecture/preserving-productive-tensions"]="architecture/preserving-productive-tensions/SKILL.md"

# Collaboration
skill_dirs["collaboration"]="collaboration"
skills["collaboration/brainstorming"]="collaboration/brainstorming/SKILL.md"
skills["collaboration/dispatching-parallel-agents"]="collaboration/dispatching-parallel-agents/SKILL.md"
skills["collaboration/executing-plans"]="collaboration/executing-plans/SKILL.md"
skills["collaboration/finishing-a-development-branch"]="collaboration/finishing-a-development-branch/SKILL.md"
skills["collaboration/receiving-code-review"]="collaboration/receiving-code-review/SKILL.md"
skills["collaboration/remembering-conversations"]="collaboration/remembering-conversations/SKILL.md"
skills["collaboration/requesting-code-review"]="collaboration/requesting-code-review/SKILL.md"
skills["collaboration/subagent-driven-development"]="collaboration/subagent-driven-development/SKILL.md"
skills["collaboration/using-git-worktrees"]="collaboration/using-git-worktrees/SKILL.md"
skills["collaboration/writing-plans"]="collaboration/writing-plans/SKILL.md"

# Debugging
skill_dirs["debugging"]="debugging"
skills["debugging/defense-in-depth"]="debugging/defense-in-depth/SKILL.md"
skills["debugging/root-cause-tracing"]="debugging/root-cause-tracing/SKILL.md"
skills["debugging/systematic-debugging"]="debugging/systematic-debugging/SKILL.md"
skills["debugging/verification-before-completion"]="debugging/verification-before-completion/SKILL.md"

# Meta
skill_dirs["meta"]="meta"
skills["meta/gardening-skills-wiki"]="meta/gardening-skills-wiki/SKILL.md"
skills["meta/pulling-updates-from-skills-repository"]="meta/pulling-updates-from-skills-repository/SKILL.md"
skills["meta/sharing-skills"]="meta/sharing-skills/SKILL.md"
skills["meta/testing-skills-with-subagents"]="meta/testing-skills-with-subagents/SKILL.md"
skills["meta/writing-skills"]="meta/writing-skills/SKILL.md"

# Problem-solving
skill_dirs["problem-solving"]="problem-solving"
skills["problem-solving/collision-zone-thinking"]="problem-solving/collision-zone-thinking/SKILL.md"
skills["problem-solving/inversion-exercise"]="problem-solving/inversion-exercise/SKILL.md"
skills["problem-solving/meta-pattern-recognition"]="problem-solving/meta-pattern-recognition/SKILL.md"
skills["problem-solving/scale-game"]="problem-solving/scale-game/SKILL.md"
skills["problem-solving/simplification-cascades"]="problem-solving/simplification-cascades/SKILL.md"
skills["problem-solving/when-stuck"]="problem-solving/when-stuck/SKILL.md"

# Research
skill_dirs["research"]="research"
skills["research/tracing-knowledge-lineages"]="research/tracing-knowledge-lineages/SKILL.md"

# Testing
skill_dirs["testing"]="testing"
skills["testing/condition-based-waiting"]="testing/condition-based-waiting/SKILL.md"
skills["testing/test-driven-development"]="testing/test-driven-development/SKILL.md"
skills["testing/testing-anti-patterns"]="testing/testing-anti-patterns/SKILL.md"

# Using-skills
skill_dirs["using-skills"]="using-skills"
skills["using-skills/find-skills"]="using-skills/find-skills/SKILL.md"
skills["using-skills/skill-run"]="using-skills/skill-run/SKILL.md"

# 创建目录
for dir in "${skill_dirs[@]}"; do
    mkdir -p "$OUTPUT_DIR/$dir"
done

# 下载所有 skill 文件
echo "开始下载 skills..."
for key in "${!skills[@]}"; do
    path="${skills[$key]}"
    output_path="$OUTPUT_DIR/$path"
    mkdir -p "$(dirname "$output_path")"
    echo "下载: $path"
    curl -sL "$BASE_URL/$path" -o "$output_path" 2>/dev/null
    if [ -s "$output_path" ]; then
        echo "  ✓ 成功"
    else
        echo "  ✗ 失败或为空"
    fi
done

echo "下载完成！"
echo "文件保存在: $OUTPUT_DIR"
