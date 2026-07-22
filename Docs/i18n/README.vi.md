<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Phát triển, kiểm thử và gỡ lỗi trò chơi Godot bằng AI
@description: Máy chủ MCP mã nguồn mở cho phát triển trò chơi Godot tự động bằng AI. Playtest tất định, kiểm thử nhiều người chơi, gỡ lỗi DAP, tích hợp LSP, tiết kiệm token. 100% MIT.
@keywords: godot mcp, model context protocol, phát triển trò chơi bằng ai, godot ai, kiểm thử trò chơi, playtest, kiểm thử tất định, kiểm thử nhiều người chơi, gỡ lỗi trò chơi, dap debugger, tích hợp lsp, gdscript, godot 4, mcp mã nguồn mở, trợ lý lập trình ai, claude mcp, ai game engine, kiểm thử trò chơi tự động, plugin godot, hiệu quả token
@author: MasterYee Labs
@language: vi
@og:type: software
@og:title: Open Godot MCP
@og:description: Máy chủ MCP mã nguồn mở cho phát triển trò chơi Godot bằng AI — playtest tất định, kiểm thử nhiều người chơi, gỡ lỗi DAP, LSP, tiết kiệm token.
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
  "description": "Máy chủ Model Context Protocol mã nguồn mở cho phát triển, kiểm thử và gỡ lỗi trò chơi Godot tự động bằng AI. Tính năng bao gồm playtest tất định, kiểm thử nhiều người chơi, gỡ lỗi DAP, tích hợp LSP và thiết kế tiết kiệm token.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Playtest tất định (freeze/step/step_until)",
    "Kiểm thử trò chơi nhiều người chơi (đa thực thể, mô phỏng peer)",
    "Gỡ lỗi DAP (breakpoints, stack_trace, variables, evaluate)",
    "Tích hợp LSP (chẩn đoán, tự động hoàn thành, go-to-definition)",
    "Thiết kế tiết kiệm token (tóm tắt JSON, diff, nén ảnh chụp)",
    "30+ công cụ MCP, 130+ hành động",
    "Ổn định kết nối (heartbeat, tự kết nối lại thông minh, tự động tránh xung đột cổng)"
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

> Máy chủ Model Context Protocol mã nguồn mở, miễn phí, đầy đủ tính năng cho phép AI tự động phát triển, kiểm thử và gỡ lỗi trò chơi Godot — bao gồm điều khiển trò chơi thực tế, playtest tất định, kiểm thử nhiều người chơi, gỡ lỗi DAP, tích hợp LSP và thiết kế tiết kiệm token. 100% giấy phép MIT, không freemium, không paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](../../README.md) | [English](README_EN.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | Tiếng Việt（本檔） | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP là gì?

**Open Godot MCP** là máy chủ [Model Context Protocol](https://modelcontextprotocol.io) mã nguồn mở kết nối các trợ lý lập trình AI (Claude, GPT, Cursor, Windsurf, v.v.) với trình soạn thảo [Godot Engine](https://godotengine.org). Nó cho phép AI **viết mã, chạy trò chơi, kiểm thử lối chơi, gỡ lỗi tại điểm ngắt, kiểm tra biến và xác minh bản sửa** — tất cả tự động, không cần con người can thiệp.

Khác với các máy chủ Godot MCP hiện có chỉ chỉnh sửa scene, Open Godot MCP cho phép AI **thực sự chơi trò chơi** thông qua playtest tất định (đóng băng đồng hồ → bước thời gian → quan sát trạng thái → xác minh kết quả). Đây là Godot MCP **duy nhất** hỗ trợ **kiểm thử trò chơi nhiều người chơi**, **tích hợp gỡ lỗi DAP** và **trí thông minh mã LSP**.

| Thuộc tính | Giá trị |
|-----------|---------|
| **Loại dự án** | Máy chủ MCP (Model Context Protocol) cho Godot Engine |
| **Engine mục tiêu** | Godot 4.5+ (hỗ trợ GDScript + C#) |
| **Runtime** | Python 3.11+ (máy chủ) + GDScript (addon) |
| **Giấy phép** | MIT (100% mã nguồn mở, không freemium) |
| **Công cụ** | ~30 công cụ MCP, ~130 hành động |
| **Tính năng chính** | Playtest tất định, kiểm thử nhiều người chơi, gỡ lỗi DAP, LSP, hiệu quả token |
| **Máy khách AI** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, bất kỳ máy khách tương thích MCP nào |
| **Nền tảng** | Windows, macOS, Linux |
| **Khả năng độc nhất** | Kiểm thử nhiều người chơi (không Godot MCP nào có), tích hợp DAP + LSP |

---

## Tại sao dự án này tồn tại

Mọi Godot MCP trên thị trường đều có nhược điểm:

| Vấn đề | Các MCP hiện có | Open Godot MCP |
|---------|--------------|-----------------|
| AI không thể thấy trò chơi chạy thực tế | Chỉ chỉnh sửa, không thể chạy trò chơi để sửa lỗi | **Playtest tất định** — đóng băng đồng hồ, bước thời gian chính xác, step_until theo điều kiện |
| Kết nối không ổn định | Cổng cố định, không có heartbeat, xung đột WSL2 | Cổng có thể cấu hình + heartbeat + tự kết nối lại thông minh + tự động tránh xung đột cổng |
| Không thể kiểm thử nhiều người chơi | Tất cả MCP đều thiếu kiểm thử nhiều người chơi | **Độc nhất** — đa thực thể, mô phỏng peer, xác minh đồng bộ, chèn điều kiện mạng |
| Lãng phí token | Trả về toàn bộ, PNG không nén, không có diff | Quan sát tiết kiệm, nén ảnh chụp, diff, tóm tắt, truy vấn tăng dần |
| Phiên bản miễn phí bị cắt giảm tính năng | Phiên bản miễn phí bị giới hạn, trả tiền để dùng tính năng | **100% mã nguồn mở MIT**, tất cả tính năng miễn phí |

---

## Dành cho ai?

- **Nhà phát triển trò chơi sử dụng Godot 4** muốn AI giúp viết, kiểm thử và gỡ lỗi trò chơi
- **Người lập trình có hỗ trợ AI** (Claude, Cursor, Windsurf, người dùng VS Code MCP) đang làm việc trên dự án Godot
- **Studio trò chơi độc lập** cần playtest tự động mà không phải viết framework kiểm thử
- **Nhà phát triển trò chơi nhiều người chơi** cần kiểm thử đồng bộ mạng, độ trễ và hành vi peer
- **Người ủng hộ mã nguồn mở** muốn máy chủ MCP hoàn toàn miễn phí, không paywall

---

## Trường hợp sử dụng

| Trường hợp | Open Godot MCP giúp thế nào |
|----------|--------------------------|
| **AI sửa lỗi di chuyển** | AI đặt điểm ngắt → chạy trò chơi → kiểm tra biến → xác định nguyên nhân gốc → sửa mã → kiểm thử lại |
| **Kiểm thử đánh boss tự động** | Đóng băng đồng hồ → sinh boss → bước thời gian → mô phỏng input né tránh → xác minh người chơi sống sót |
| **Xác minh đồng bộ nhiều người chơi** | Khởi chạy thực thể host + client → chèn độ trễ → so sánh trạng thái đồng bộ → phát hiện lỗi desync |
| **Phân tích hiệu suất** | Chụp ảnh profiler → xác định spike → tối ưu → đo lại |
| **Kiểm thử hồi quy** | Chạy bộ kiểm thử sau khi thay mã → xác nhận trạng thái trò chơi khớp kỳ vọng |
| **Lặp lại thiết kế màn chơi** | AI tạo node → sắp xếp scene → chạy trò chơi → chụp màn hình kết quả → điều chỉnh |

---

## Các khả năng cốt lõi

### 1. Playtest tất định (giải quyết "AI không thể thấy trò chơi chạy")

AI không chỉ viết mã — nó có thể **tự chơi trò chơi để xác minh các bản sửa**:

```
godot_game play frozen=true                    # Khởi chạy trò chơi (đồng hồ đóng băng)
godot_exec eval code="GameState.wave = 3"      # Thiết lập kịch bản kiểm thử
godot_game_time step_until "boss.size() >= 1"  # Chờ boss xuất hiện
godot_runtime_state digest                     # Quan sát trạng thái (JSON, không tốn token hình ảnh)
godot_game_time step ms=500 + dodge input      # Chơi khoảnh khắc quan trọng
godot_screenshot game                          # Chụp màn hình chỉ khi đáng giá
```

### 2. Kiểm thử nhiều người chơi (tính năng độc nhất — không Godot MCP nào có)

Một khả năng mà không Godot MCP nào hiện có:

```
godot_network launch_instance role="host"      # Khởi động máy chủ
godot_network launch_instance role="client"    # Khởi động máy khách
godot_network network_condition latency=200    # Chèn độ trễ 200ms
godot_network sync_state                       # Xác minh đồng bộ đa thực thể
godot_network simulate_peer count=50           # Kiểm thử áp lực 50 peer
```

### 3. Hiệu quả token

Mọi công cụ đều có thiết kế tiết kiệm token:

- **Quan sát tiết kiệm**: Tóm tắt trạng thái JSON thay thế ảnh chụp màn hình (tiết kiệm 90% token)
- **Trả về diff**: Chỉ trả về phần thay đổi
- **Nén ảnh chụp**: JPEG/WebP + lưu vào ổ đĩa (không nằm trong context)
- **Tách biệt đọc/ghi**: đọc tự động cho phép, ghi bị kiểm soát
- **Thao tác hàng loạt**: Hoàn thành nhiều thao tác trong một chuyến đi

### 4. Ổn định kết nối

Giải quyết vấn đề "không thể kết nối" trong các MCP hiện có:

- Cổng có thể cấu hình (env > EditorSettings > tự tránh xung đột)
- Phát hiện đặt trước cổng Windows (tránh cổng dành riêng cho Hyper-V/WSL2/Docker)
- Cơ chế heartbeat (phát hiện chủ động kết nối đã chết)
- Tự kết nối lại thông minh (backoff hàm mũ + số lần thử tối đa + thông báo UI)

### 5. Gỡ lỗi hoàn chỉnh

- **DAP (Debugger Adapter Protocol)**: điểm ngắt, bước, kiểm tra biến (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: chẩn đoán tĩnh, tự động hoàn thành, go-to-definition
- **Profiler**: ảnh chụp hiệu suất, phân tích timeline, phát hiện spike

---

## Bắt đầu nhanh

### 1. Cài đặt máy chủ MCP

```bash
uv tool install open-godot-mcp
# hoặc
pip install open-godot-mcp
```

### 2. Cấu hình máy khách AI

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Mở dự án Godot

Addon tự động chèn. Mở máy khách AI và bắt đầu sử dụng.

Hướng dẫn cài đặt đầy đủ: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Danh sách công cụ

~30 công cụ, ~130 hành động. Thiết kế tách biệt đọc/ghi.

| Lĩnh vực | Công cụ | Mô tả |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | Trạng thái, scene, lựa chọn |
| Scene | `godot_scene` | Tạo, đọc, lưu |
| Node | `godot_node_read/edit` | CRUD, thuộc tính, nhóm, signal |
| Script | `godot_script` | Chỉnh sửa diff, xác thực |
| Project | `godot_project` | Cài đặt, autoload |
| Input Map | `godot_input_map` | Quản lý InputMap |
| Resource | `godot_resource` | Kiểm tra theo kiểu |
| Animation | `godot_animation` | Tạo, track, preset |
| TileMapLayer | `godot_tilemap` | Đọc/ghi ô |
| **Điều khiển trò chơi** | `godot_game` | play/stop/freeze |
| **Đồng hồ** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Bàn phím/chuột/gamepad/văn bản |
| **Trạng thái** | `godot_runtime_state` | digest/watch/signals |
| **Chèn mã** | `godot_exec` | eval/call/assert |
| Ảnh chụp màn hình | `godot_screenshot` | Nén, lưu vào tệp |
| Debugger | `godot_debugger` | Điểm ngắt DAP, stack_trace, variables, evaluate |
| Mã | `godot_lsp` | Chẩn đoán, hoàn thành |
| Profiler | `godot_profiler` | Ảnh chụp, timeline |
| Kiểm thử | `godot_test` | Framework, thực thi |
| **Mạng** | `godot_network` | Đa thực thể, đồng bộ, điều kiện mạng |
| Instance | `godot_instance` | Quản lý đa Godot |
| Filesystem | `godot_filesystem` | Đọc/ghi, tìm kiếm |
| Docs | `godot_docs` | Theo phiên bản |
| Log | `godot_log` | Truy vấn tăng dần |
| Batch | `godot_batch` | Nhiều thao tác cùng lúc |
| Asset | `godot_asset` | Tạo, quản lý |
| Export | `godot_export` | Preset, xuất |
| Health | `godot_health` | Kiểm tra kết nối |

API đầy đủ: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## So sánh với các máy chủ Godot MCP hiện có

| Tính năng | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Thao tác editor | ✅ | ✅ | ✅ | ✅ | ✅ 149 công cụ | ✅ |
| Điều khiển trò chơi thực tế | ⚠️ | ⚠️ | ❌ | ✅ tất định | ⚠️ | ✅ **tất định+thời gian thực** |
| Kiểm thử nhiều người chơi | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **độc nhất** |
| Gỡ lỗi DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Tích hợp LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Hiệu quả token | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **toàn diện** |
| Ổn định kết nối | ⚠️ | ❌ | — | ✅ | — | ✅ **ổn định nhất** |
| Giấy phép | mở | mở | MIT | MIT | MIT | **MIT** |

---

## Câu hỏi thường gặp

### Model Context Protocol (MCP) là gì?

[Model Context Protocol](https://modelcontextprotocol.io) là một tiêu chuẩn mở cho phép các trợ lý AI kết nối với các công cụ và nguồn dữ liệu bên ngoài. Open Godot MCP là máy chủ MCP kết nối AI với trình soạn thảo Godot Engine.

### Những phiên bản Godot nào được hỗ trợ?

Godot 4.5 trở lên. Addon sử dụng API Godot 4.x bao gồm `EditorDebuggerPlugin`, `EditorInspector` và kênh tin nhắn debugger.

### Những máy khách AI nào tương thích?

Bất kỳ máy khách tương thích MCP nào: Claude Desktop, Cursor, Windsurf, VS Code (với tiện ích MCP), Continue, Zed và bất kỳ máy khách nào hỗ trợ tiêu chuẩn Model Context Protocol.

### Có hỗ trợ C# (phiên bản .NET của Godot) không?

Có. Kiểm tra cú pháp C# và xác thực biên dịch được hỗ trợ. Xem [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Điều này khác gì so với các máy chủ Godot MCP khác?

Open Godot MCP là Godot MCP **duy nhất** hỗ trợ kiểm thử trò chơi nhiều người chơi, tích hợp gỡ lỗi DAP (điểm ngắt, stack trace, kiểm tra biến) và trí thông minh mã LSP. Nó cũng có thiết kế hiệu quả token toàn diện nhất.

### Thực sự miễn phí không?

Có. 100% giấy phép MIT, không mô hình freemium, không paywall, không giới hạn tính năng. Tất cả tính năng đều miễn phí cho mọi người.

### AI có thực sự chơi được trò chơi không?

Có. Thông qua playtest tất định, AI có thể đóng băng đồng hồ trò chơi, bước thời gian theo từng khoảng chính xác, chèn kịch bản kiểm thử, mô phỏng input người chơi, quan sát trạng thái trò chơi dưới dạng JSON và chụp màn hình — tất cả để xác minh các thay đổi mã hoạt động đúng.

### Kiểm thử nhiều người chơi hoạt động thế nào?

Open Godot MCP có thể khởi chạy nhiều thực thể Godot (host + client), mô phỏng peer, chèn điều kiện mạng (độ trễ, mất gói tin) và xác minh rằng trạng thái trò chơi được đồng bộ hóa giữa các thực thể.

---

## Tài liệu

Chỉ mục tài liệu đầy đủ: [Docs/README.md](Docs/README.md). Tách biệt theo thư mục.

| Thư mục | Nội dung |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Tổng quan tính năng, triết lý thiết kế |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Kiến trúc, giao thức, ổn định kết nối, đa thực thể, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Danh sách công cụ đầy đủ (theo lĩnh vực) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Playtest tất định (Hướng dẫn + Ví dụ) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Thiết kế tiết kiệm token (Hướng dẫn + Chiến lược) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Kiểm thử nhiều người chơi (Hướng dẫn + Ví dụ) |
| [Docs/06-Installation/](Docs/06-Installation/) | Cài đặt (Hướng dẫn + Khắc phục sự cố) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Lộ trình phát triển |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Tương thích C# Godot & kiểm tra cú pháp |
| [Docs/09-Research/](Docs/09-Research/) | Nghiên cứu MCP hiện có, nghiên cứu C# MCP |

---

## Lời cảm ơn

Open Godot MCP đứng trên vai người khổng lồ, lấy những điều tốt nhất từ:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k sao) — kiến trúc nền tảng
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — playtest tất định, quan sát tiết kiệm, tách biệt đọc/ghi
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime kênh debugger, Undo/Redo, đặt trước cổng Windows, 20+ cấu hình máy khách, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — kiến trúc kênh kép, tuần tự hóa Variant, bảo vệ xóa
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — tích hợp DAP + LSP, đa thực thể, cô lập cổng
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — không dấu vết, khái niệm Playwright cho Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — tham chiếu độ rộng 149 công cụ

---

## Giấy phép

[MIT](LICENSE) — 100% mã nguồn mở, tất cả tính năng miễn phí, không freemium, không paywall.
