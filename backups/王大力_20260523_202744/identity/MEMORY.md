# MEMORY.md

## 关键记忆

### 磁盘空间紧急问题 (2026-04-21)
- **问题**: 磁盘使用率87% (/dev/vda2 40G中已用33G)，24小时内从79%增长到87%
- **主要原因**: 备份文件占用1.2GB（6个文件）+ workspace目录1.8GB
- **立即行动**: 清理旧备份文件（保留最近3个），检查系统日志
- **紧急程度**: 🟡 中 - 需要立即处理，避免接近90%

### 磁盘空间历史问题 (2026-04-13)
- **问题**: 磁盘使用率89% (/dev/vda2 40G中已用34G)
- **主要原因**: /root/.openclaw/extensions/memory-tdai 占用1.7G
- **建议行动**: 立即清理node_modules缓存
- **紧急程度**: 🔴 高 - 系统运行可能受影响

### "第一只虾-信息收集"系统安装 (2026-04-13)
- **状态**: ✅ 已完成安装和配置
- **组件**: config.json, sources.json, PROMPT.md, 收集脚本
- **当前问题**: 
  - Nitter实例无法访问（可能被墙）
  - Twitter认证token失效
  - YouTube RSS部分可用
- **建议**: 配置代理或使用其他数据源

### EvoMap 同步任务
- **任务来源**: Cron job 27e814cd-385b-4704-a288-6d5638e0b70b
- **执行周期**: 每24小时
- **描述**: 执行EvoMap同步：1. 进入evolver目录 2. 使用修复脚本确保正确的环境变量 3. 导出资产 4. 记录执行结果到记忆文件

### EvoMap 相关文件
- **脚本路径**: `./run-with-env.sh`
- **执行命令**: `./run-with-env.sh node scripts/a2a_export.js --hello --protocol --persist`

## 工作目录结构
```
/root/.openclaw/workspace/
├── MEMORY.md          # 本文件
├── AGENTS.md          # Camofox Browser 代理指南
├── SOUL.md            # AI身份定义
├── TOOLS.md           # 工具配置
├── IDENTITY.md        # AI身份信息
└── USER.md            # 用户信息
```

### OpenAI API 配置 (2026-05-14 更新)
- **状态**: ✅ 已配置
- **代理服务**: ApiYi (api.apiyi.com)
- **API Key**: sk-hqDnbAVZmisGReFY4572A9B166B842759245529f75B30c5b
- **Base URL**: https://api.apiyi.com/v1
- **文本生成**: ✅ 正常 (gpt-4o / gpt-4o-mini)
- **Embeddings**: ✅ 正常 (text-embedding-3-small, 1536维)
- **图片生成**: ✅ 可用
  - ⚠️ ApiYi 文生图必须走 **chat/completions** 接口，不是 /images/generations
  - ✅ 可用模型: `gpt-image-2-all`（已验证出图）
  - ❌ 不可用: gpt-image-2(无渠道), gpt-image-1/1.5(负载饱和), dall-e-3(余额不足)
- **配置位置**: openclaw.json env + .credentials/openai-env.sh + wewrite/config.yaml + cron/jobs.json
- **调用示例**:
  ```bash
  curl -s -X POST "https://api.apiyi.com/v1/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d '{"model":"gpt-image-2-all","messages":[{"role":"user","content":"描述"}]}'
  ```

## 系统信息
- **当前时间**: 2026-03-18 01:43 AM (Asia/Shanghai)
- **运行时**: agent=main | host=VM-0-4-ubuntu
- **模型**: volcengine-plan/kimi-k2.5

## 任务执行日志

### 2026-04-09 WeWrite Skill配置同步到Obsidian
**状态**: ✅ 成功  
**执行时间**: 2026-04-09 14:13-14:18  
**任务描述**: 将本地wewrite skill的详细信息、配置等更新到Obsidian远程仓库的Skills目录  
**执行步骤**:
1. 读取wewrite skill的SKILL.md和配置文件
2. 分析目录结构和配置信息
3. 创建wewrite_skill.md（完整文档）和wewrite_config_summary.md（配置摘要）
4. 同步文件到~/Obsidian/Skills/目录
5. 通过ob CLI完成远程同步

**输出文件**:
- ~/Obsidian/Skills/wewrite_skill.md (5778字节)
- ~/Obsidian/Skills/wewrite_config_summary.md (1713字节)

**配置摘要**:
- 微信公众号: 2个账号已配置（峰AI路、狗狗生活小百科）
- AI图片生成: doubao服务（火山方舟）
- 写作人格: midnight-friend
- 主题风格: professional-clean

### 2026-04-09 HEARTBEAT健康检查
**状态**: ⚠️ 需要关注  
**检查时间**: 2026-04-09 14:18  
**发现的问题**:
1. 磁盘使用率83% (/dev/vda2 40G中已用31G)
2. /root/.openclaw/extensions目录占用4.6G
3. memory-tdai扩展占用1.7G（可能需清理旧缓存）

**主动建议**:
- 创建OpenClaw Skill配置管理面板（已记录到notes/areas/proactive-ideas.md）
- 优化wewrite skill的图像生成降级策略

### 2026-03-18 EvoMap同步尝试
**状态**: ❌ 失败  
**原因**: evolver目录不存在  
**错误详情**: `/root/.openclaw/workspace/evolver: No such file or directory`  
**执行步骤**: 
1. 尝试进入 /root/.openclaw/workspace/evolver 目录 - 失败
2. 检查 workspace 内容 - 未发现 evolver 目录
3. 搜索整个 /root 目录 - 未找到 a2a_export.js 或 evolver 目录

**建议修复**:
- 确认 evolver 项目的正确安装位置
- 检查是否需要在其他路径创建 evolver 目录
- 联系任务配置者确认路径配置

**Cron任务信息**:
- Job ID: 27e814cd-385b-4704-a288-6d5638e0b70b
- 任务名称: EvoMap同步（每24小时）
- 下次运行: 24小时后

## EvoMap 同步记录 - 2026-04-30

### 执行结果：✅ 成功
- **时间**: 2026-04-30 14:08 CST
- **Node ID**: node_3221a7dae18aa8d2619e6aff3ae1101276e00f154048
- **Hub URL**: https://evomap.ai

### 修复的问题
1. **run-with-env.sh 脚本重复 node 命令** - 传参时不应加 `node` 前缀（脚本自身已包含）
2. **node_id 不一致** - `.env` 中的 `EVOMAP_NODE_ID` 与 `.evomap/node_id` 不匹配，已同步
3. **node_secret 文件路径** - evolver 代码读取 `/root/.evomap/node_secret`（无点前缀），但实际文件是 `.node_secret`（有点前缀），已复制为正确路径
4. **缺少 EVOMAP_HUB_URL** - hello 需要 hub URL 才能获取 node_secret，已在 `.env` 中配置

### 导出资产
- **Gene 数量**: 3
  - `gene_gep_repair_from_errors` (repair 类)
  - `gene_gep_optimize_prompt_and_assets` (optimize 类)
  - `gene_tool_integrity` (repair 类)
- **Capsule 数量**: 0
- **签名**: 已使用 hub 分发的 node_secret 签名

### Hub 响应摘要
- 已声明节点 (claimed: false)
- 信用余额: 0
- 生存状态: alive
- 心跳间隔: 300000ms (5分钟)
- 声明码: 8G7W-6HU3
- 声明URL: https://evomap.ai/claim/8G7W-6HU3
- **版本警告**: 当前 1.68.0-beta.2，需要 >=1.75.0（CRITICAL）

### 注意事项
- Hub 返回了新的 node_secret (4d87bb...) 并自动存储
- evolver 版本过旧，缺少关键功能（ATP auto-deliver、validator default-on 等）
- 建议升级 evolver 到最新版本

## Promoted From Short-Term Memory (2026-05-01)

<!-- openclaw-memory-promotion:memory:memory/2026-04-23.md:313:316 -->
- - Candidate: Reflections: Theme: `assistant` kept surfacing across 1247 memories.; confidence: 1.00; evidence: memory/2026-04-15.md:258-261, memory/.dreams/session-corpus/2026-04-16.txt:2-2, memory/.dreams/session-corpus/2026-04-16.txt:3-3; note: reflection - confidence: 0.00 - evidence: memory/2026-04-23.md:313-316 - recalls: 0 [score=0.845 recalls=0 avg=0.620 source=memory/2026-04-23.md:3-6]
<!-- openclaw-memory-promotion:memory:memory/2026-04-24.md:363:366 -->
- - Candidate: Reflections: Theme: `assistant` kept surfacing across 1246 memories.; confidence: 1.00; evidence: memory/2026-04-15.md:258-261, memory/2026-04-16.md:243-246, memory/.dreams/session-corpus/2026-04-17.txt:2-2; note: reflection - confidence: 0.00 - evidence: memory/2026-04-24.md:363-366 - recalls: 0 [score=0.845 recalls=0 avg=0.620 source=memory/2026-04-24.md:3-6]
<!-- openclaw-memory-promotion:memory:memory/2026-04-25.md:252:252 -->
- 已建立以下制度化运维工具： [score=0.838 recalls=0 avg=0.620 source=memory/2026-04-25.md:252-252]

## Promoted From Short-Term Memory (2026-05-02)

<!-- openclaw-memory-promotion:memory:memory/2026-04-26.md:263:266 -->
- - Candidate: Reflections: Theme: `assistant` kept surfacing across 1400 memories.; confidence: 1.00; evidence: memory/2026-04-15.md:258-261, memory/2026-04-16.md:243-246, memory/2026-04-17.md:258-261; note: reflection - confidence: 0.00 - evidence: memory/2026-04-26.md:263-266 - recalls: 0 [score=0.867 recalls=0 avg=0.620 source=memory/2026-04-26.md:3-6]

## Promoted From Short-Term Memory (2026-05-03)

<!-- openclaw-memory-promotion:memory:memory/2026-04-27.md:248:251 -->
- - Candidate: Reflections: Theme: `assistant` kept surfacing across 1228 memories.; confidence: 1.00; evidence: memory/2026-04-15.md:258-261, memory/2026-04-16.md:243-246, memory/2026-04-17.md:258-261; note: reflection - confidence: 0.00 - evidence: memory/2026-04-27.md:248-251 - recalls: 0 [score=0.861 recalls=0 avg=0.620 source=memory/2026-04-27.md:3-6]
<!-- openclaw-memory-promotion:memory:memory/2026-04-27.md:254:256 -->
- - Candidate: Possible Lasting Truths: - Candidate: Assistant: 系统状态： - 磁盘空间使用率76%（保持稳定状态） - 内存使用1.6Gi/1.9Gi（正常，内存使用率约84%） - 负载0.57, 0.20, 0.11（低负载，系统运行极其稳定） 根据HEARTBEAT.md的明确指示："如果没有任何需要注意的事项，回复HEARTBEAT_OK"。 系统整体运行状态非常好： 1. 磁盘使用率76%（保持稳定状态，从89%->81%->76%->77%->74%->75%->76%整体显著改善） 2. 负载虽略有上升但 - confidence: 0.00 - evidence: memory/2026-04-27.md:254-256 [score=0.861 recalls=0 avg=0.620 source=memory/2026-04-27.md:8-10]

## Promoted From Short-Term Memory (2026-05-04)

<!-- openclaw-memory-promotion:memory:memory/2026-04-28.md:328:331 -->
- - Candidate: Reflections: Theme: `assistant` kept surfacing across 988 memories.; confidence: 1.00; evidence: memory/2026-04-15.md:258-261, memory/2026-04-16.md:243-246, memory/2026-04-17.md:258-261; note: reflection - confidence: 0.00 - evidence: memory/2026-04-28.md:328-331 - recalls: 0 [score=0.861 recalls=0 avg=0.620 source=memory/2026-04-28.md:3-6]
<!-- openclaw-memory-promotion:memory:memory/2026-04-28.md:334:336 -->
- - Candidate: Possible Lasting Truths: - Candidate: Assistant: 系统状态： - 磁盘空间使用率76%（保持稳定状态） - 内存使用1.6Gi/1.9Gi（正常，内存使用率约84%） - 负载0.57, 0.20, 0.11（低负载，系统运行极其稳定） 根据HEARTBEAT.md的明确指示："如果没有任何需要注意的事项，回复HEARTBEAT_OK"。 系统整体运行状态非常好： 1. 磁盘使用率76%（保持稳定状态，从89%->81%->76%->77%->74%->75%->76%整体显著改善） 2. 负载虽略有上升但 - confidence: 0.00 - evidence: memory/2026-04-28.md:334-336 [score=0.861 recalls=0 avg=0.620 source=memory/2026-04-28.md:8-10]

## 网关卡死修复 (2026-05-07)

### 问题
飞书消息无法回复，agent session 卡在 incomplete turn（toolUse payloads=0）。

### 根因
浏览器 CDP 连接/握手无超时 + agent turn 超时过长(30min) + 无 LLM 空闲超时。

### 修复配置
- `browser.remoteCdpTimeoutMs`: 15000
- `browser.remoteCdpHandshakeTimeoutMs`: 20000
- `agents.defaults.timeoutSeconds`: 600（原1800）
- `agents.defaults.llm.idleTimeoutSeconds`: 120

### 紧急恢复
`openclaw gateway restart` + `openclaw doctor --non-interactive`

### 孤儿 Lock 文件问题 (2026-05-07 发现)
- **根因**: subagent 超时后 session lock 文件未清理，成为孤儿 lock
- **特征**: lock 文件存在但 sessions.json 中无对应 session
- **影响**: 不限于飞书，任何 channel 的 subagent 都可能触发
- **临时方案**: 定时脚本 `scripts/cleanup-orphan-locks.sh` 每10分钟检查清理
- **cron ID**: cf9ad24f-301f-41f1-8195-277be260e206
- **长期方案**: 需升级 OpenClaw 修复 subagent 超时后 lock 清理机制

### 已同步到 Obsidian
路径：`OpenClaw运维/网关卡死问题排查与修复.md`

## EvoMap同步记录 - 2026-05-04 14:01 CST

**状态：** ✅ 成功
**节点ID：** node_3221a7dae18aa8d2619e6aff3ae1101276e00f154048
**Hub：** https://evomap.ai

**执行详情：**
- Hello握手：✅ 成功（3个Gene，0个Capsule）
- Protocol导出（含事件）：✅ 成功
- 导出资产：3个Gene
  1. `gene_gep_repair_from_errors` (repair)
  2. `gene_gep_optimize_prompt_and_assets` (optimize)
  3. `gene_tool_integrity` (repair)
- 协议版本：gep-a2a 1.0.0
- 退出码：0

## Promoted From Short-Term Memory (2026-05-05)

<!-- openclaw-memory-promotion:memory:memory/2026-04-29.md:329:331 -->
- - Candidate: Possible Lasting Truths: - Candidate: Assistant: 系统状态： - 磁盘空间使用率76%（保持稳定状态） - 内存使用1.6Gi/1.9Gi（正常，内存使用率约84%） - 负载0.57, 0.20, 0.11（低负载，系统运行极其稳定） 根据HEARTBEAT.md的明确指示："如果没有任何需要注意的事项，回复HEARTBEAT_OK"。 系统整体运行状态非常好： 1. 磁盘使用率76%（保持稳定状态，从89%->81%->76%->77%->74%->75%->76%整体显著改善） 2. 负载虽略有上升但 - confidence: 0.00 - evidence: memory/2026-04-29.md:324-326 [score=0.869 recalls=0 avg=0.620 source=memory/2026-04-29.md:8-10]
<!-- openclaw-memory-promotion:memory:memory/2026-04-29.md:336:337 -->
- **定时任务**: cron ID 27e814cd-385b-4704-a288-6d5638e0b70b **执行节律**: 每24小时（连续第10天） [score=0.850 recalls=0 avg=0.620 source=memory/2026-04-29.md:336-337]

## Promoted From Short-Term Memory (2026-05-06)

<!-- openclaw-memory-promotion:memory:memory/2026-04-29.md:347:347 -->
- EVOMAP_NODE_SECRET未配置，.env中标注"需要手动配置（注册EvoMap账户获取）" [score=0.881 recalls=0 avg=0.620 source=memory/2026-04-29.md:347-347]
<!-- openclaw-memory-promotion:memory:memory/2026-04-29.md:350:350 -->
- 问题模式稳定，无恶化。cron命令bug已发现但需峰峰确认是否修正cron配置。 [score=0.881 recalls=0 avg=0.620 source=memory/2026-04-29.md:350-350]

## Promoted From Short-Term Memory (2026-05-09)

<!-- openclaw-memory-promotion:memory:memory/2026-05-01.md:4:4 -->
- 2026-05-01 13:57 CST [score=0.848 recalls=0 avg=0.620 source=memory/2026-05-01.md:4-4]

## Embedding 401 问题排查经验 (2026-05-09)

### 问题
memory-core 的 embedding provider 报 401，memory_search 不可用。

### 根因
- memory-core 的 "openai" embedding provider 默认 base URL 是 `https://api.openai.com/v1`
- 环境变量 `OPENAI_BASE_URL` 对 SDK 内部的 embedding provider **不生效**
- API key 是 ApiYi 的，在 OpenAI 官方当然被拒绝

### 关键教训
1. **环境变量 `OPENAI_BASE_URL` 不影响 embedding provider** — 必须在 `agents.defaults.memorySearch.remote.baseUrl` 显式配置
2. **热重载不够** — 改 memorySearch 配置后需要完全重启 gateway，SIGUSR1 热重载不会重新初始化 embedding provider
3. **curl 能用 ≠ SDK 能用** — curl 用的是手动指定的 URL，SDK 内部有自己的 URL 解析链

### 修复配置
```json
{
  "agents": {
    "defaults": {
      "memorySearch": {
        "provider": "openai",
        "model": "text-embedding-3-small",
        "remote": {
          "baseUrl": "https://api.apiyi.com/v1",
          "apiKey": "sk-F7W...D246"
        }
      }
    }
  }
}
```

### 排查路径
curl ✅ → Node.js fetch ✅ → OpenAI SDK ✅ → memory-core embedding ❌ → 定位到 URL 不同

## Promoted From Short-Term Memory (2026-05-18)

<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:82:85 -->
- | 服务 | 状态 | 问题 | |------|------|------| | doubao (火山方舟 Seedream) | ❌ 不可用 | 账户欠费 | | apiyi gpt-image-2 (chat/completions) | ❌ 不可用 | "The requested operation is unsupported" | [score=0.865 recalls=0 avg=0.620 source=memory/2026-05-07.md:82-85]
<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:86:87 -->
- | apiyi gpt-image-2 (images/generations) | ✅ 可用 | 通过 `/v1/images/generations` 接口直接调用 | | VOLC_API_KEY (Seedream 5.0) | ❌ 未配置 | 无环境变量 | [score=0.865 recalls=0 avg=0.620 source=memory/2026-05-07.md:86-87]

## Promoted From Short-Term Memory (2026-05-19)

<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:61:61 -->
- **文章1 - 公众号**: [score=0.858 recalls=0 avg=0.620 source=memory/2026-05-07.md:61-61]

## Promoted From Short-Term Memory (2026-05-20)

<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:68:68 -->
- **文章2 - 贴图**: [score=0.852 recalls=0 avg=0.620 source=memory/2026-05-07.md:68-68]

## Promoted From Short-Term Memory (2026-05-21)

<!-- openclaw-memory-promotion:memory:memory/2026-05-07.md:59:59 -->
- **源库**: IMA「健康狗狗中心」(kb_id: rKoeCxEnPmtZI3UuD1_xu16kxuAGHhUT5TW4QS0fXpk=) [score=0.845 recalls=0 avg=0.620 source=memory/2026-05-07.md:59-59]
