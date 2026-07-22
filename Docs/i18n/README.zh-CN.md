<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI 驱动的 Godot 游戏开发、测试与调试
@description: 开源 MCP 服务器，支持 AI 自主开发 Godot 游戏。确定性试玩、多人联机测试、DAP 调试、LSP 集成、token 节省。100% MIT。
@keywords: godot mcp, 模型上下文协议, ai 游戏开发, godot ai, 游戏测试, 试玩, 确定性测试, 多人联机测试, 游戏调试, dap 调试器, lsp 集成, gdscript, godot 4, 开源 mcp, ai 编程助手, claude mcp, 游戏引擎 ai, 自动化游戏测试, godot 插件, token 节省
@author: MasterYee Labs
@language: zh-CN
@og:type: software
@og:title: Open Godot MCP
@og:description: 开源 MCP 服务器，支持 AI 驱动的 Godot 游戏开发——确定性试玩、多人联机测试、DAP 调试、LSP 集成、token 节省。
-->

<!--
JSON-LD Structured Data (Schema.org SoftwareApplication)
=========================================================
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "SoftwareApplication",
  "name": "Open Godot MCP",
  "applicationCategory": "DeveloperApplication",
  "operatingSystem": "Cross-platform",
  "softwareVersion": "0.1.0",
  "license": "https://opensource.org/licenses/MIT",
  "description": "开源模型上下协议服务器，支持 AI 自主开发、测试和调试 Godot 游戏。具备确定性试玩、多人联机测试、DAP 调试、LSP 集成和 token 节省设计。",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "确定性试玩（freeze/step/step_until）",
    "多人联机游戏测试（多实例、对等端模拟）",
    "DAP 调试（断点、stack_trace、variables、evaluate）",
    "LSP 集成（诊断、自动补全、跳转定义）",
    "Token 节省设计（JSON 摘要、差异对比、截图压缩）",
    "30+ MCP 工具，130+ 操作",
    "连接稳定性（心跳、智能重连、端口自动避让）"
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "5",
    "reviewCount": "1"
  }
}
</script>
-->

# Open Godot MCP

> 开源、免费、功能齐全的模型上下文协议（MCP）服务器，让 AI 自主开发、测试和调试 Godot 游戏——包括真实游戏控制、确定性试玩、多人联机测试、DAP 调试、LSP 集成和 token 节省设计。100% MIT 许可证，无免费版阉割，无付费墙。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](../../README.md) | [English](README.en.md) | 简体中文（本檔） | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## 什么是 Open Godot MCP？

**Open Godot MCP** 是一个开源的[模型上下文协议](https://modelcontextprotocol.io)服务器，将 AI 编程助手（Claude、GPT、Cursor、Windsurf 等）连接到 [Godot Engine](https://godotengine.org) 编辑器。它让 AI 能够**编写代码、运行游戏、测试游戏玩法、在断点处调试、检查变量并验证修复**——全部自主完成，无需人工干预。

与仅能编辑场景的现有 Godot MCP 服务器不同，Open Godot MCP 让 AI 通过确定性试玩**真正运行游戏**（冻结时钟 → 步进时间 → 观察状态 → 验证结果）。它是**唯一**支持**多人联机游戏测试**、**DAP 调试器集成**和 **LSP 代码智能**的 Godot MCP。

| 属性 | 值 |
|-----------|-------|
| **项目类型** | Godot Engine 的 MCP 服务器（模型上下文协议） |
| **目标引擎** | Godot 4.5+（支持 GDScript + C#） |
| **运行时** | Python 3.11+（服务器）+ GDScript（插件） |
| **许可证** | MIT（100% 开源，无免费版阉割） |
| **工具** | ~30 个 MCP 工具，~130 个操作 |
| **核心功能** | 确定性试玩、多人联机测试、DAP 调试、LSP、token 节省 |
| **AI 客户端** | Claude Desktop、Cursor、Windsurf、VS Code（MCP）、Continue、Zed 及任何兼容 MCP 的客户端 |
| **平台** | Windows、macOS、Linux |
| **独有能力** | 多人联机测试（无其他 Godot MCP 具备）、DAP + LSP 集成 |

---

## 为什么开发这个项目

市面上的每一个 Godot MCP 都存在不足：

| 问题 | 现有 MCP | Open Godot MCP |
|---------|--------------|-----------------|
| AI 看不到游戏实际运行 | 仅能编辑，无法运行游戏来修复 bug | **确定性试玩**——冻结时钟、精确步进时间、step_until 条件等待 |
| 连接不稳定 | 硬编码端口、无心跳、WSL2 冲突 | 可配置端口 + 心跳 + 智能重连 + 端口自动避让 |
| 无法测试多人联机 | 所有 MCP 都缺乏多人联机测试 | **独有功能**——多实例、对等端模拟、同步验证、网络条件注入 |
| Token 浪费 | 完整返回、未压缩 PNG、无差异对比 | 低成本观察、截图压缩、差异对比、摘要、增量查询 |
| 免费版阉割 | 免费版功能受限，付费解锁 | **100% MIT 开源**，所有功能免费 |

---

## 适合谁用？

- **使用 Godot 4 的游戏开发者**，希望 AI 帮助编写、测试和调试游戏
- **AI 辅助编程者**（Claude、Cursor、Windsurf、VS Code MCP 用户），正在开发 Godot 项目
- **独立游戏工作室**，需要自动化试玩测试而无需编写测试框架
- **多人联机游戏开发者**，需要测试网络同步、延迟和对等端行为
- **开源倡导者**，希望拥有完全免费、无付费墙的 MCP 服务器

---

## 使用场景

| 使用场景 | Open Godot MCP 如何帮助 |
|----------|--------------------------|
| **AI 修复移动 bug** | AI 设置断点 → 运行游戏 → 检查变量 → 定位根因 → 修复代码 → 重新测试 |
| **自动化 Boss 战测试** | 冻结时钟 → 生成 Boss → 步进时间 → 模拟闪避输入 → 验证玩家存活 |
| **多人联机同步验证** | 启动主机 + 客户端实例 → 注入延迟 → 比较同步状态 → 检测不同步 bug |
| **性能分析** | 采集性能快照 → 定位峰值 → 优化 → 重新测量 |
| **回归测试** | 代码变更后运行测试套件 → 断言游戏状态符合预期 |
| **关卡设计迭代** | AI 创建节点 → 布置场景 → 运行游戏 → 截图结果 → 调整 |

---

## 核心能力

### 1. 确定性试玩（解决"AI 看不到游戏运行"问题）

AI 不仅仅是写代码——它还能**亲自运行游戏来验证修复效果**：

```
godot_game play frozen=true                    # 启动游戏（冻结时钟）
godot_exec eval code="GameState.wave = 3"      # 设置测试场景
godot_game_time step_until "boss.size() >= 1"  # 等待 Boss 出现
godot_runtime_state digest                     # 观察状态（JSON，不消耗视觉 token）
godot_game_time step ms=500 + dodge input      # 游玩关键时刻
godot_screenshot game                          # 仅在值得时截图
```

### 2. 多人联机测试（独有功能——无其他 Godot MCP 具备此能力）

现有 Godot MCP 都不具备的能力：

```
godot_network launch_instance role="host"      # 启动服务器
godot_network launch_instance role="client"    # 启动客户端
godot_network network_condition latency=200    # 注入 200ms 延迟
godot_network sync_state                       # 验证多实例同步
godot_network simulate_peer count=50           # 50 个对等端压力测试
```

### 3. Token 节省

每个工具都内置了节省 token 的设计：

- **低成本观察**：JSON 状态摘要替代截图（节省 90% token）
- **差异返回**：仅返回发生变化的部分
- **截图压缩**：JPEG/WebP + 保存到磁盘（不放入上下文）
- **读写分离**：读取自动放行，写入需授权
- **批量操作**：一次往返完成多个操作

### 4. 连接稳定性

解决现有 MCP 的"连不上"问题：

- 可配置端口（环境变量 > EditorSettings > 自动避让）
- Windows 端口保留检测（避开 Hyper-V/WSL2/Docker 保留端口）
- 心跳机制（主动检测死连接）
- 智能重连（指数退避 + 最大重试次数 + UI 通知）

### 5. 完整调试

- **DAP**：断点、单步、变量检查（stack_trace、variables、evaluate）
- **LSP**：静态诊断、自动补全、跳转定义
- **性能分析器**：性能快照、时间线分析、峰值检测

---

## 快速开始

### 1. 安装 MCP 服务器

```bash
uv tool install open-godot-mcp
# 或
pip install open-godot-mcp
```

### 2. 配置 AI 客户端

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. 打开 Godot 项目

插件会自动注入。打开你的 AI 客户端即可开始使用。

完整安装指南：[Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md)。

---

## 工具列表

约 30 个工具，约 130 个操作。采用读写分离设计。

| 领域 | 工具 | 说明 |
|--------|------|-------------|
| 编辑器 | `godot_editor_read/edit` | 状态、场景、选择 |
| 场景 | `godot_scene` | 创建、读取、保存 |
| 节点 | `godot_node_read/edit` | 增删改查、属性、分组、信号 |
| 脚本 | `godot_script` | 差异编辑、校验 |
| 项目 | `godot_project` | 设置、自动加载 |
| 输入映射 | `godot_input_map` | InputMap 管理 |
| 资源 | `godot_resource` | 类型感知检查 |
| 动画 | `godot_animation` | 创建、轨道、预设 |
| TileMapLayer | `godot_tilemap` | 单元格读写 |
| **游戏控制** | `godot_game` | play/stop/freeze |
| **时钟** | `godot_game_time` | freeze/step/step_until |
| **输入** | `godot_input` | 键盘/鼠标/手柄/文本 |
| **状态** | `godot_runtime_state` | digest/watch/signals |
| **注入** | `godot_exec` | eval/call/assert |
| 截图 | `godot_screenshot` | 压缩、保存到文件 |
| 调试器 | `godot_debugger` | DAP 断点、stack_trace、variables、evaluate |
| 代码 | `godot_lsp` | 诊断、补全 |
| 性能分析器 | `godot_profiler` | 快照、时间线 |
| 测试 | `godot_test` | 框架、执行 |
| **网络** | `godot_network` | 多实例、同步、网络条件 |
| 实例 | `godot_instance` | 多 Godot 管理 |
| 文件系统 | `godot_filesystem` | 读写、搜索 |
| 文档 | `godot_docs` | 版本匹配 |
| 日志 | `godot_log` | 增量查询 |
| 批量 | `godot_batch` | 一次性多个操作 |
| 资产 | `godot_asset` | 生成、管理 |
| 导出 | `godot_export` | 预设、导出 |
| 健康 | `godot_health` | 连接检查 |

完整 API：[Docs/02-Tools/Index.md](Docs/02-Tools/Index.md)。

---

## 与现有 Godot MCP 服务器对比

| 功能 | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| 编辑器操作 | ✅ | ✅ | ✅ | ✅ | ✅ 149 个工具 | ✅ |
| 真实游戏控制 | ⚠️ | ⚠️ | ❌ | ✅ 确定性 | ⚠️ | ✅ **确定性+实时** |
| 多人联机测试 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **独有** |
| DAP 调试 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP 集成 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token 节省 | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **全面** |
| 连接稳定性 | ⚠️ | ❌ | — | ✅ | — | ✅ **最稳定** |
| 许可证 | 开源 | 开源 | MIT | MIT | MIT | **MIT** |

---

## 常见问题

### 什么是模型上下文协议（MCP）？

[模型上下文协议](https://modelcontextprotocol.io)是一个开放标准，让 AI 助手能够连接外部工具和数据源。Open Godot MCP 是一个 MCP 服务器，将 AI 连接到 Godot Engine 编辑器。

### 支持哪些 Godot 版本？

Godot 4.5 及更新版本。插件使用 Godot 4.x API，包括 `EditorDebuggerPlugin`、`EditorInspector` 和调试器消息通道。

### 兼容哪些 AI 客户端？

任何兼容 MCP 的客户端：Claude Desktop、Cursor、Windsurf、VS Code（需 MCP 扩展）、Continue、Zed，以及任何支持模型上下文协议标准的客户端。

### 是否支持 C#（Godot 的 .NET 版本）？

支持。C# 语法检查和编译验证均已支持。详见 [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/)。

### 与其他 Godot MCP 服务器有什么不同？

Open Godot MCP 是**唯一**支持多人联机游戏测试、DAP 调试器集成（断点、调用栈、变量检查）和 LSP 代码智能的 Godot MCP。它还拥有最全面的 token 节省设计。

### 真的免费吗？

是的。100% MIT 许可证，无免费版阉割模式，无付费墙，无功能限制。所有功能对所有人免费。

### AI 真的能运行游戏吗？

能。通过确定性试玩，AI 可以冻结游戏时钟、按精确增量步进时间、注入测试场景、模拟玩家输入、以 JSON 观察游戏状态并截图——全部用于验证代码变更是否正确生效。

### 多人联机测试如何工作？

Open Godot MCP 可以启动多个 Godot 实例（主机 + 客户端）、模拟对等端、注入网络条件（延迟、丢包），并验证游戏状态在各实例间是否同步。

---

## 文档

完整文档索引：[Docs/README.md](Docs/README.md)。按文件夹分模块。

| 文件夹 | 内容 |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | 功能概览、设计理念 |
| [Docs/01-Architecture/](Docs/01-Architecture/) | 架构、协议、连接稳定性、多实例、运行时 |
| [Docs/02-Tools/](Docs/02-Tools/) | 完整工具列表（按领域分文件） |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | 确定性试玩（指南 + 示例） |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Token 节省设计（指南 + 策略） |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | 多人联机测试（指南 + 示例） |
| [Docs/06-Installation/](Docs/06-Installation/) | 安装（指南 + 故障排查） |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | 开发路线图 |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot 兼容性与语法检查 |
| [Docs/09-Research/](Docs/09-Research/) | 现有 MCP 研究、C# MCP 研究 |

---

## 致谢

Open Godot MCP 站在巨人的肩膀上，汲取了以下项目的精华：

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)（4.8k stars）——基础架构
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp)——确定性试玩、低成本观察、读写分离
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai)——调试器通道运行时、Undo/Redo、Windows 端口保留、20+ 客户端配置、McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp)——双通道架构、Variant 序列化、删除保护
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp)——DAP + LSP 集成、多实例、端口隔离
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime)——零足迹、Godot 版 Playwright 概念
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp)——149 个工具的广度参考

---

## 许可证

[MIT](LICENSE)——100% 开源，所有功能免费，无免费版阉割，无付费墙。
