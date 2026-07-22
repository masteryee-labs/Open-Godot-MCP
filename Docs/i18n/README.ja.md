<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI 駆動の Godot ゲーム開発・テスト・デバッグ
@description: AI 自律型 Godot ゲーム開発のためのオープンソース MCP サーバー。決定論的プレイテスト、マルチプレイヤーテスト、DAP デバッグ、LSP 統合、トークン効率。100% MIT。
@keywords: godot mcp, model context protocol, ai ゲーム開発, godot ai, ゲームテスト, プレイテスト, 決定論的テスト, マルチプレイヤーテスト, ゲームデバッグ, dap デバッガ, lsp 統合, gdscript, godot 4, オープンソース mcp, ai コーディングアシスタント, claude mcp, ゲームエンジン ai, 自動ゲームテスト, godot プラグイン, トークン効率
@author: MasterYee Labs
@language: ja
@og:type: software
@og:title: Open Godot MCP
@og:description: AI 駆動の Godot ゲーム開発のためのオープンソース MCP サーバー — 決定論的プレイテスト、マルチプレイヤーテスト、DAP デバッグ、LSP、トークン効率。
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
  "description": "AI 自律型 Godot ゲーム開発・テスト・デバッグのためのオープンソース Model Context Protocol サーバー。決定論的プレイテスト、マルチプレイヤーテスト、DAP デバッグ、LSP 統合、トークン効率設計を備えています。",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "決定論的プレイテスト（freeze/step/step_until）",
    "マルチプレイヤーゲームテスト（マルチインスタンス、ピアシミュレーション）",
    "DAP デバッグ（ブレークポイント、stack_trace、variables、evaluate）",
    "LSP 統合（診断、自動補完、定義ジャンプ）",
    "トークン効率設計（JSON ダイジェスト、差分、スクリーンショット圧縮）",
    "30 以上の MCP ツール、130 以上のアクション",
    "接続の安定性（ハートビート、スマート再接続、ポート自動回避）"
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

> オープンソース・無料・フル機能の Model Context Protocol (MCP) サーバー。AI が Godot ゲームを自律的に開発・テスト・デバッグできるようにします — 実際のゲーム制御、決定論的プレイテスト、マルチプレイヤーテスト、DAP デバッグ、LSP 統合、トークン効率設計を含みます。100% MIT ライセンス、フリーミアムなし、ペイウォールなし。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](../../README.md) | [English](README.en.md) | [简体中文](README.zh-CN.md) | 日本語（本檔） | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP とは？

**Open Godot MCP** は、AI コーディングアシスタント（Claude、GPT、Cursor、Windsurf など）を [Godot Engine](https://godotengine.org) エディタに接続するオープンソースの [Model Context Protocol](https://modelcontextprotocol.io) サーバーです。AI が**コードを書き、ゲームを実行し、ゲームプレイをテストし、ブレークポイントでデバッグし、変数を検査し、修正を検証**することを — すべて人間の介入なしで自律的に可能にします。

シーンの編集しかできない既存の Godot MCP サーバーとは異なり、Open Godot MCP は AI に**実際にゲームをプレイ**させることができます — 決定論的プレイテスト（クロックを固定 → 時間をステップ → 状態を観測 → 結果を検証）を通じて。**マルチプレイヤーゲームテスト**、**DAP デバッガ統合**、**LSP コードインテリジェンス**をサポートする**唯一の** Godot MCP です。

| 属性 | 値 |
|-----------|-------|
| **プロジェクト種別** | Godot Engine 用 MCP サーバー（Model Context Protocol） |
| **対象エンジン** | Godot 4.5+（GDScript + C# サポート） |
| **ランタイム** | Python 3.11+（サーバー）+ GDScript（アドオン） |
| **ライセンス** | MIT（100% オープンソース、フリーミアムなし） |
| **ツール** | 約 30 の MCP ツール、約 130 のアクション |
| **主要機能** | 決定論的プレイテスト、マルチプレイヤーテスト、DAP デバッグ、LSP、トークン効率 |
| **AI クライアント** | Claude Desktop、Cursor、Windsurf、VS Code (MCP)、Continue、Zed、MCP 互換クライアントすべて |
| **プラットフォーム** | Windows、macOS、Linux |
| **独自機能** | マルチプレイヤーテスト（他の Godot MCP にはない）、DAP + LSP 統合 |

---

## なぜこのプロジェクトが存在するのか

市場にあるすべての Godot MCP には欠点があります：

| 問題 | 既存の MCP | Open Godot MCP |
|---------|--------------|-----------------|
| AI がゲームが実際に動くのを見られない | 編集のみ、バグ修正のためにゲームをプレイできない | **決定論的プレイテスト** — クロックを固定、正確な時間をステップ、step_until 条件 |
| 接続が不安定 | ポート固定、ハートビートなし、WSL2 の競合 | 設定可能なポート + ハートビート + スマート再接続 + ポート自動回避 |
| マルチプレイヤーをテストできない | すべての MCP にマルチプレイヤーテストがない | **独自** — マルチインスタンス、ピアシミュレーション、同期検証、ネットワーク条件注入 |
| トークンの無駄遣い | 全件返却、非圧縮 PNG、差分なし | 低コスト観測、スクリーンショット圧縮、差分、要約、増分クエリ |
| フリーミアムの制限 | 無料版は機能制限、機能を使うには課金 | **100% MIT オープンソース**、すべての機能が無料 |

---

## 対象読者

- **Godot 4 を使うゲーム開発者** — AI にゲームの作成・テスト・デバッグを手伝わせたい人
- **AI アシストコーダー**（Claude、Cursor、Windsurf、VS Code MCP ユーザー）— Godot プロジェクトに取り組む人
- **インディーゲームスタジオ** — テストフレームワークを書かずに自動プレイテストが必要な人
- **マルチプレイヤーゲーム開発者** — ネットワーク同期、レイテンシ、ピア挙動をテストする必要がある人
- **オープンソース推進者** — ペイウォールのない完全無料の MCP サーバーを求める人

---

## ユースケース

| ユースケース | Open Godot MCP がどう役立つか |
|----------|--------------------------|
| **AI が移動バグを修正** | AI がブレークポイントを設定 → ゲーム実行 → 変数検査 → 根本原因を特定 → コード修正 → 再テスト |
| **ボス戦の自動テスト** | クロックを固定 → ボスをスポーン → 時間をステップ → 回避入力をシミュレート → プレイヤー生存を検証 |
| **マルチプレイヤー同期検証** | ホスト + クライアントインスタンスを起動 → レイテンシを注入 → 同期状態を比較 → デシンクバグを検出 |
| **パフォーマンスプロファイリング** | プロファイラスナップショットを取得 → スパイクを特定 → 最適化 → 再計測 |
| **リグレッションテスト** | コード変更後にテストスイートを実行 → ゲーム状態が期待値と一致することを確認 |
| **レベルデザインの反復** | AI がノードを作成 → シーンを配置 → ゲーム実行 → 結果をスクリーンショット → 調整 |

---

## コア機能

### 1. 決定論的プレイテスト（「AI がゲームの実行を見られない」問題を解決）

AI はコードを書くだけでなく、**自らゲームをプレイして修正を検証**できます：

```
godot_game play frozen=true                    # ゲーム起動（クロック固定）
godot_exec eval code="GameState.wave = 3"      # テストシナリオをセットアップ
godot_game_time step_until "boss.size() >= 1"  # ボス出現を待機
godot_runtime_state digest                     # 状態を観測（JSON、ビジョントークン不要）
godot_game_time step ms=500 + dodge input      # 重要な場面をプレイ
godot_screenshot game                          # 価値がある時だけスクリーンショット
```

### 2. マルチプレイヤーテスト（独自機能 — 他の Godot MCP にはない）

既存の Godot MCP にはない機能です：

```
godot_network launch_instance role="host"      # サーバー起動
godot_network launch_instance role="client"    # クライアント起動
godot_network network_condition latency=200    # 200ms のレイテンシを注入
godot_network sync_state                       # マルチインスタンスの同期を検証
godot_network simulate_peer count=50           # 50 ピアのストレステスト
```

### 3. トークン効率

すべてのツールにトークン節約設計があります：

- **低コスト観測**：JSON の状態ダイジェストがスクリーンショットを代替（トークンを 90% 削減）
- **差分返却**：変更された部分のみ返却
- **スクリーンショット圧縮**：JPEG/WebP + ディスクに保存（コンテキスト内に保持しない）
- **読み書き分離**：読み取りは自動許可、書き込みはゲート制御
- **バッチ操作**：1 ラウンドトリップで複数操作を完了

### 4. 接続の安定性

既存の MCP の「接続できない」問題を解決します：

- 設定可能なポート（環境変数 > EditorSettings > 自動回避）
- Windows ポート予約の検出（Hyper-V/WSL2/Docker の予約ポートを回避）
- ハートビート機構（デッド接続の能動的検出）
- スマート再接続（指数バックオフ + 最大リトライ回数 + UI 通知）

### 5. 完全なデバッグ

- **DAP（Debugger Adapter Protocol）**：ブレークポイント、ステップ実行、変数検査（stack_trace、variables、evaluate）
- **LSP（Language Server Protocol）**：静的診断、自動補完、定義ジャンプ
- **プロファイラ**：パフォーマンススナップショット、タイムライン分析、スパイク検出

---

## クイックスタート

### 1. MCP サーバーをインストール

```bash
uv tool install open-godot-mcp
# or
pip install open-godot-mcp
```

### 2. AI クライアントを設定

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot プロジェクトを開く

アドオンは自動注入されます。AI クライアントを開いて使い始めてください。

完全なインストールガイド：[Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md)。

---

## ツール一覧

約 30 のツール、約 130 のアクション。読み書き分離設計。

| ドメイン | ツール | 説明 |
|--------|------|-------------|
| エディタ | `godot_editor_read/edit` | 状態、シーン、選択 |
| シーン | `godot_scene` | 作成、読み取り、保存 |
| ノード | `godot_node_read/edit` | CRUD、プロパティ、グループ、シグナル |
| スクリプト | `godot_script` | 差分編集、検証 |
| プロジェクト | `godot_project` | 設定、オートロード |
| 入力マップ | `godot_input_map` | InputMap 管理 |
| リソース | `godot_resource` | 型対応検査 |
| アニメーション | `godot_animation` | 作成、トラック、プリセット |
| TileMapLayer | `godot_tilemap` | セルの読み書き |
| **ゲーム制御** | `godot_game` | play/stop/freeze |
| **クロック** | `godot_game_time` | freeze/step/step_until |
| **入力** | `godot_input` | キーボード/マウス/ゲームパッド/テキスト |
| **状態** | `godot_runtime_state` | digest/watch/signals |
| **注入** | `godot_exec` | eval/call/assert |
| スクリーンショット | `godot_screenshot` | 圧縮、ファイル保存 |
| デバッガ | `godot_debugger` | DAP ブレークポイント、stack_trace、variables、evaluate |
| コード | `godot_lsp` | 診断、補完 |
| プロファイラ | `godot_profiler` | スナップショット、タイムライン |
| テスト | `godot_test` | フレームワーク、実行 |
| **ネットワーク** | `godot_network` | マルチインスタンス、同期、ネットワーク条件 |
| インスタンス | `godot_instance` | マルチ Godot 管理 |
| ファイルシステム | `godot_filesystem` | 読み書き、検索 |
| ドキュメント | `godot_docs` | バージョン対応 |
| ログ | `godot_log` | 増分クエリ |
| バッチ | `godot_batch` | 複数操作を一括実行 |
| アセット | `godot_asset` | 生成、管理 |
| エクスポート | `godot_export` | プリセット、エクスポート |
| ヘルス | `godot_health` | 接続チェック |

完全な API：[Docs/02-Tools/Index.md](Docs/02-Tools/Index.md)。

---

## 既存の Godot MCP サーバーとの比較

| 機能 | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| エディタ操作 | ✅ | ✅ | ✅ | ✅ | ✅ 149 ツール | ✅ |
| 実際のゲーム制御 | ⚠️ | ⚠️ | ❌ | ✅ 決定論的 | ⚠️ | ✅ **決定論的+リアルタイム** |
| マルチプレイヤーテスト | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **独自** |
| DAP デバッグ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP 統合 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| トークン効率 | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **包括的** |
| 接続の安定性 | ⚠️ | ❌ | — | ✅ | — | ✅ **最も安定** |
| ライセンス | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Model Context Protocol (MCP) とは何ですか？

[Model Context Protocol](https://modelcontextprotocol.io) は、AI アシスタントが外部ツールやデータソースに接続できるようにするオープン標準です。Open Godot MCP は、AI を Godot Engine エディタに接続する MCP サーバーです。

### どの Godot バージョンがサポートされていますか？

Godot 4.5 以降です。アドオンは `EditorDebuggerPlugin`、`EditorInspector`、デバッガメッセージチャネルなど Godot 4.x API を使用しています。

### どの AI クライアントと互換性がありますか？

MCP 互換のすべてのクライアント：Claude Desktop、Cursor、Windsurf、VS Code（MCP 拡張機能付き）、Continue、Zed、および Model Context Protocol 標準をサポートするすべてのクライアント。

### C#（Godot の .NET 版）はサポートされていますか？

はい。C# の構文チェックとコンパイル検証がサポートされています。[Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) を参照してください。

### 他の Godot MCP サーバーとどう違いますか？

Open Godot MCP は、マルチプレイヤーゲームテスト、DAP デバッガ統合（ブレークポイント、スタックトレース、変数検査）、LSP コードインテリジェンスをサポートする**唯一の** Godot MCP です。また、最も包括的なトークン効率設計を備えています。

### 本当に無料ですか？

はい。100% MIT ライセンス、フリーミアムモデルなし、ペイウォールなし、機能制限なし。すべての機能が誰でも無料で利用できます。

### AI は実際にゲームをプレイできますか？

はい。決定論的プレイテストを通じて、AI はゲームクロックを固定し、正確な刻みで時間を進め、テストシナリオを注入し、プレイヤー入力をシミュレートし、ゲーム状態を JSON として観測し、スクリーンショットを撮ることができます — すべてコード変更が正しく機能することを検証するためです。

### マルチプレイヤーテストはどのように機能しますか？

Open Godot MCP は複数の Godot インスタンス（ホスト + クライアント）を起動し、ピアをシミュレートし、ネットワーク条件（レイテンシ、パケットロス）を注入し、ゲーム状態がインスタンス間で同期されていることを検証できます。

---

## ドキュメント

完全なドキュメントインデックス：[Docs/README.md](Docs/README.md)。フォルダごとに分離されています。

| フォルダ | 内容 |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | 機能概要、設計思想 |
| [Docs/01-Architecture/](Docs/01-Architecture/) | アーキテクチャ、プロトコル、接続の安定性、マルチインスタンス、ランタイム |
| [Docs/02-Tools/](Docs/02-Tools/) | 完全なツール一覧（ドメイン別ファイル） |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | 決定論的プレイテスト（ガイド + 例） |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | トークン節約設計（ガイド + 戦略） |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | マルチプレイヤーテスト（ガイド + 例） |
| [Docs/06-Installation/](Docs/06-Installation/) | インストール（ガイド + トラブルシューティング） |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | 開発ロードマップ |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot 互換性 & 構文チェック |
| [Docs/09-Research/](Docs/09-Research/) | 既存 MCP の研究、C# MCP の研究 |

---

## 謝辞

Open Godot MCP は巨人の肩の上に立ち、以下から最良のものを取り入れています：

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp)（4.8k スター）— 基盤アーキテクチャ
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — 決定論的プレイテスト、低コスト観測、読み書き分離
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — デバッガチャネルランタイム、Undo/Redo、Windows ポート予約、20+ クライアント設定、McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — デュアルチャネルアーキテクチャ、Variant シリアライゼーション、削除保護
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP 統合、マルチインスタンス、ポート分離
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — ゼロフットプリント、Godot 版 Playwright のコンセプト
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149 ツールの網羅的リファレンス

---

## ライセンス

[MIT](LICENSE) — 100% オープンソース、すべての機能が無料、フリーミアムなし、ペイウォールなし。
