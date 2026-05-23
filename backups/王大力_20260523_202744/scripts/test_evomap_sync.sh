#!/bin/bash

echo "🚀 EvoMap同步配置测试"
echo "========================"
echo ""

# 1. 进入evolver目录
echo "1. 📁 进入evolver目录"
cd /root/.openclaw/workspace/evolver || { echo "❌ 无法进入evolver目录"; exit 1; }
echo "   ✅ 当前目录: $(pwd)"
echo ""

# 2. 检查目录结构
echo "2. 🔍 检查目录结构"
if [ -f "run-with-env.sh" ]; then
    echo "   ✅ run-with-env.sh存在"
else
    echo "   ❌ run-with-env.sh不存在"
fi

if [ -f "scripts/a2a_export.js" ]; then
    echo "   ✅ scripts/a2a_export.js存在"
else
    echo "   ❌ scripts/a2a_export.js不存在"
fi

if [ -f ".env" ]; then
    echo "   ✅ .env文件存在"
    echo "   📄 .env内容:"
    cat .env | while read line; do echo "      $line"; done
else
    echo "   ⚠️  .env文件不存在（将使用默认值）"
fi
echo ""

# 3. 测试第一个命令
echo "3. 🔧 测试hello消息和协议"
echo "   执行: ./run-with-env.sh scripts/a2a_export.js --hello --protocol --persist"
echo ""
./run-with-env.sh node scripts/a2a_export.js --hello --protocol --persist
EXIT_CODE1=$?
echo ""
if [ $EXIT_CODE1 -eq 0 ]; then
    echo "   ✅ 第一个命令执行成功"
else
    echo "   ❌ 第一个命令执行失败 (退出码: $EXIT_CODE1)"
fi
echo ""

# 4. 测试第二个命令
echo "4. 📦 测试资产导出（包含事件）"
echo "   执行: ./run-with-env.sh scripts/a2a_export.js --protocol --persist --include-events"
echo ""
./run-with-env.sh node scripts/a2a_export.js --protocol --persist --include-events
EXIT_CODE2=$?
echo ""
if [ $EXIT_CODE2 -eq 0 ]; then
    echo "   ✅ 第二个命令执行成功"
else
    echo "   ❌ 第二个命令执行失败 (退出码: $EXIT_CODE2)"
fi
echo ""

# 5. 总结
echo "5. 📊 测试总结"
echo "   ============"
if [ $EXIT_CODE1 -eq 0 ] && [ $EXIT_CODE2 -eq 0 ]; then
    echo "   🎉 所有测试通过！"
    echo "   ✅ EvoMap同步配置正确"
    echo "   ✅ 脚本和环境变量工作正常"
    echo "   ✅ 可以启用定时任务"
else
    echo "   ⚠️  测试发现问题："
    if [ $EXIT_CODE1 -ne 0 ]; then
        echo "   ❌ 第一个命令失败"
    fi
    if [ $EXIT_CODE2 -ne 0 ]; then
        echo "   ❌ 第二个命令失败"
    fi
    echo "   🔧 需要修复配置问题"
fi
echo ""

# 6. 建议
echo "6. 💡 后续建议"
echo "   - 安装实际的evolver Node.js包"
echo "   - 配置真正的node_secret（从EvoMap获取）"
echo "   - 更新.env文件包含完整配置"
echo "   - 测试与真实EvoMap Hub的连接"
echo "   - 启用24小时同步任务"
echo ""

echo "🏁 测试完成"