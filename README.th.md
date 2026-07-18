<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — พัฒนา ทดสอบ และดีบักเกม Godot ด้วย AI
@description: เซิร์ฟเวอร์ MCP แบบโอเพนซอร์สสำหรับพัฒนาเกม Godotด้วย AI อิสระ การเล่นทดสอบแบบกำหนดได้ การทดสอบมัลติเพลเยอร์ ดีบัก DAP ผสานรวม LSP ประหยัดโทเคน 100% MIT
@keywords: godot mcp, model context protocol, ai game development, godot ai, game testing, playtesting, deterministic testing, multiplayer testing, game debugging, dap debugger, lsp integration, gdscript, godot 4, open source mcp, ai coding assistant, claude mcp, game engine ai, automated game testing, godot plugin, token efficiency
@author: MasterYee Labs
@language: th
@og:type: software
@og:title: Open Godot MCP
@og:description: เซิร์ฟเวอร์ MCP แบบโอเพนซอร์สสำหรับพัฒนาเกม Godot ด้วย AI — การเล่นทดสอบแบบกำหนดได้ การทดสอบมัลติเพลเยอร์ ดีบัก DAP ผสานรวม LSP ประหยัดโทเคน
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
  "description": "เซิร์ฟเวอร์ Model Context Protocol แบบโอเพนซอร์สสำหรับพัฒนา ทดสอบ และดีบักเกม Godot ด้วย AI อิสระ มีการเล่นทดสอบแบบกำหนดได้ การทดสอบมัลติเพลเยอร์ ดีบัก DAP ผสานรวม LSP และการออกแบบประหยัดโทเคน",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "การเล่นทดสอบแบบกำหนดได้ (freeze/step/step_until)",
    "การทดสอบเกมมัลติเพลเยอร์ (หลายอินสแตนซ์ จำลอง peer)",
    "ดีบัก DAP (เบรกพอยต์, stack_trace, variables, evaluate)",
    "ผสานรวม LSP (การวินิจฉัย การเติมอัตโนมัติ ไปยังนิยาม)",
    "การออกแบบประหยัดโทเคน (สรุป JSON, diff, บีบอัดสกรีนช็อต)",
    "30+ เครื่องมือ MCP, 130+ การดำเนินการ",
    "ความเสถียรการเชื่อมต่อ (heartbeat, เชื่อมต่อใหม่อัจฉริยะ, หลีกเลี่ยงพอร์ตอัตโนมัติ)"
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

> เซิร์ฟเวอร์ Model Context Protocol แบบโอเพนซอร์ส ฟรี ฟีเจอร์ครบครัน ที่ให้ AI พัฒนา ทดสอบ และดีบักเกม Godot ได้ด้วยตัวเอง — รวมถึงการควบคุมเกมจริง การเล่นทดสอบแบบกำหนดได้ การทดสอบมัลติเพลเยอร์ ดีบัก DAP ผสานรวม LSP และการออกแบบประหยัดโทเคน สัญญาอนุญาต MIT 100% ไม่มีฟรีเมียม ไม่มีกำแพงจ่ายเงิน

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP คืออะไร?

**Open Godot MCP** คือเซิร์ฟเวอร์ [Model Context Protocol](https://modelcontextprotocol.io) แบบโอเพนซอร์สที่เชื่อมต่อผู้ช่วยเขียนโค้ด AI (Claude, GPT, Cursor, Windsurf ฯลฯ) เข้ากับเอดิเตอร์ [Godot Engine](https://godotengine.org) ช่วยให้ AI **เขียนโค้ด รันเกม ทดสอบเกมเพลย์ ดีบักที่เบรกพอยต์ ตรวจสอบตัวแปร และยืนยันการแก้บั๊ก** ได้ทั้งหมดโดยอิสระ ไม่ต้องมีมนุษย์ช่วย

ต่างจากเซิร์ฟเวอร์ Godot MCP ที่มีอยู่ซึ่งแก้ไขซีนได้อย่างเดียว Open Godot MCP ให้ AI **เล่นเกมจริง** ผ่านการเล่นทดสอบแบบกำหนดได้ (หยุดนาฬิกา → ก้านเวลา → สังเกตสถานะ → ยืนยันผลลัพธ์) เป็น Godot MCP **เพียงตัวเดียว** ที่รองรับ **การทดสอบเกมมัลติเพลเยอร์** **ผสานรวมดีบักเกอร์ DAP** และ **ความฉลาดโค้ด LSP**

| คุณสมบัติ | ค่า |
|-----------|-------|
| **ประเภทโปรเจกต์** | เซิร์ฟเวอร์ MCP (Model Context Protocol) สำหรับ Godot Engine |
| **เอนจินเป้าหมาย** | Godot 4.5+ (รองรับ GDScript + C#) |
| **รันไทม์** | Python 3.11+ (เซิร์ฟเวอร์) + GDScript (แอดอน) |
| **ลิขสิทธิ์** | MIT (โอเพนซอร์ส 100% ไม่มีฟรีเมียม) |
| **เครื่องมือ** | ~30 เครื่องมือ MCP, ~130 การดำเนินการ |
| **ฟีเจอร์หลัก** | การเล่นทดสอบแบบกำหนดได้ การทดสอบมัลติเพลเยอร์ ดีบัก DAP ผสานรวม LSP ประหยัดโทเคน |
| **ไคลเอนต์ AI** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed และไคลเอนต์ที่รองรับ MCP ใดๆ |
| **แพลตฟอร์ม** | Windows, macOS, Linux |
| **ความสามารถไม่ซ้ำใคร** | การทดสอบมัลติเพลเยอร์ (Godot MCP ตัวอื่นไม่มี) ผสานรวม DAP + LSP |

---

## ทำไมโปรเจกต์นี้จึงมีอยู่

MCP สำหรับ Godot ทุกตัวในตลาดมีข้อด้อน:

| ปัญหา | MCP ที่มีอยู่ | Open Godot MCP |
|---------|--------------|-----------------|
| AI มองไม่เห็นเกมที่รันจริง | แก้ไขได้อย่างเดียว เล่นเกมเพื่อแก้บั๊กไม่ได้ | **การเล่นทดสอบแบบกำหนดได้** — หยุดนาฬิกา ก้านเวลาแบบแม่นยำ ก้านจนกว่าจะตรงเงื่อนไข |
| การเชื่อมต่อไม่เสถียร | พอร์ตตายตัว ไม่มี heartbeat ขัดแย้งกับ WSL2 | พอร์ตกำหนดได้ + heartbeat + เชื่อมต่อใหม่อัจฉริยะ + หลีกเลี่ยงพอร์ตอัตโนมัติ |
| ทดสอบมัลติเพลเยอร์ไม่ได้ | MCP ทุกตัวไม่มีการทดสอบมัลติเพลเยอร์ | **ไม่ซ้ำใคร** — หลายอินสแตนซ์ จำลอง peer ตรวจสอบการซิงค์ ฉีดสภาพเครือข่าย |
| สิ้นเปลืองโทเคน | ส่งกลับทั้งหมด PNG ไม่บีบอัด ไม่มี diff | สังเกตราคาถูก บีบอัดสกรีนช็อต diff สรุป คิวรีแบบเพิ่มทีละส่วน |
| ฟรีเมียมตัดฟีเจอร์ | เวอร์ชันฟรีจำกัด จ่ายเงินเพื่อใช้ฟีเจอร์ | **โอเพนซอร์ส MIT 100%** ฟีเจอร์ทุกอย่างฟรี |

---

## เหมาะกับใคร?

- **นักพัฒนาเกมที่ใช้ Godot 4** ที่ต้องการให้ AI ช่วยเขียน ทดสอบ และดีบักเกม
- **ผู้เขียนโค้ดด้วย AI** (ผู้ใช้ Claude, Cursor, Windsurf, VS Code MCP) ที่ทำโปรเจกต์ Godot
- **สตูดิโอเกมอินดี้** ที่ต้องการเล่นทดสอบอัตโนมัติโดยไม่ต้องเขียนเฟรมเวิร์กทดสอบ
- **นักพัฒนาเกมมัลติเพลเยอร์** ที่ต้องทดสอบการซิงค์เครือข่าย ความหน่วง และพฤติกรรมของ peer
- **ผู้สนับสนุนโอเพนซอร์ส** ที่ต้องการเซิร์ฟเวอร์ MCP ฟรีไม่มีกำแพงจ่ายเงิน

---

## กรณีการใช้งาน

| กรณีการใช้งาน | Open Godot MCP ช่วยอย่างไร |
|----------|--------------------------|
| **AI แก้บั๊กการเคลื่อนไหว** | AI ตั้งเบรกพอยต์ → รันเกม → ตรวจตัวแปร → หาสาเหตุราก → แก้โค้ด → ทดสอบใหม่ |
| **ทดสอบบอสไฟต์อัตโนมัติ** | หยุดนาฬิกา → สปอนบอส → ก้านเวลา → จำลองอินพุตหลบ → ยืนยันผู้เล่นรอด |
| **ตรวจสอบการซิงค์มัลติเพลเยอร์** | เปิดอินสแตนซ์ host + client → ฉีดความหน่วง → เปรียบเทียบสถานะซิงค์ → ตรวจจับบั๊ก desync |
| **โพรไฟล์ประสิทธิภาพ** | ถ่ายสแนปช็อตโพรไฟเลอร์ → หาสไปค์ → ปรับให้เหมาะสม → วัดใหม่ |
| **ทดสอบรีเกรสชัน** | รันชุดทดสอบหลังเปลี่ยนโค้ด → ยืนยันสถานะเกมตรงค่าที่คาดหวัง |
| **วนซ้ำออกแบบด่าน** | AI สร้างโหนด → จัดซีน → รันเกม → ถ่ายสกรีนช็อตผล → ปรับ |

---

## ความสามารถหลัก

### 1. การเล่นทดสอบแบบกำหนดได้ (แก้ปัญหา "AI มองไม่เห็นเกมที่รันอยู่")

AI ไม่เพียงแค่เขียนโค้ด — แต่ยัง **เล่นเกมเองเพื่อยืนยันการแก้บั๊ก** ได้:

```
godot_game play frozen=true                    # เปิดเกม (หยุดนาฬิกา)
godot_exec eval code="GameState.wave = 3"      # ตั้งค่าสถานการณ์ทดสอบ
godot_game_time step_until "boss.size() >= 1"  # รอจนบอสปรากฏ
godot_runtime_state digest                     # สังเกตสถานะ (JSON ไม่ใช้โทเคนภาพ)
godot_game_time step ms=500 + dodge input      # เล่นช่วงเวลาสำคัญ
godot_screenshot game                          # ถ่ายสกรีนช็อตเฉพาะเมื่อคุ้ม
```

### 2. การทดสอบมัลติเพลเยอร์ (ฟีเจอร์ไม่ซ้ำใคร — Godot MCP ตัวอื่นไม่มี)

ความสามารถที่ Godot MCP ตัวอื่นไม่มี:

```
godot_network launch_instance role="host"      # เริ่มเซิร์ฟเวอร์
godot_network launch_instance role="client"    # เริ่มไคลเอนต์
godot_network network_condition latency=200    # ฉีดความหน่วง 200ms
godot_network sync_state                       # ตรวจสอบการซิงค์หลายอินสแตนซ์
godot_network simulate_peer count=50           # เครียสเทสต์ 50 peer
```

### 3. ประสิทธิภาพโทเคน

ทุกเครื่องมือออกแบบมาเพื่อประหยัดโทเคน:

- **สังเกตราคาถูก**: สรุปสถานะ JSON แทนสกรีนช็อต (ประหยัดโทเคน 90%)
- **ส่งกลับแบบ diff**: ส่งกลับเฉพาะส่วนที่เปลี่ยนแปลง
- **บีบอัดสกรีนช็อต**: JPEG/WebP + บันทึกลงดิสก์ (ไม่อยู่ในคอนเท็กซ์)
- **แยกอ่าน/เขียน**: อ่านอนุญาตอัตโนมัติ เขียนต้องผ่านเกต
- **การดำเนินการแบบกลุ่ม**: ทำหลายการดำเนินการในครั้งเดียว

### 4. ความเสถียรของการเชื่อมต่อ

แก้ปัญหา "เชื่อมต่อไม่ได้" ใน MCP ที่มีอยู่:

- พอร์ตกำหนดได้ (env > EditorSettings > หลีกเลี่ยงอัตโนมัติ)
- ตรวจจับการจองพอร์ตของ Windows (หลีกเลี่ยงพอร์ตที่ Hyper-V/WSL2/Docker สงวนไว้)
- กลไก heartbeat (ตรวจจับการเชื่อมต่อที่ตายอย่างรู้ตัว)
- เชื่อมต่อใหม่อย่างชาญฉลาด (ถดถอยแบบเอ็กซ์โพเนนเชียล + จำนวนครั้งลองสูงสุด + แจ้งเตือน UI)

### 5. การดีบักครบวงจร

- **DAP (Debugger Adapter Protocol)**: เบรกพอยต์ การก้าน การตรวจสอบตัวแปร (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: การวินิจฉัยแบบสแตติก การเติมอัตโนมัติ ไปยังนิยาม
- **โพรไฟเลอร์**: สแนปช็อตประสิทธิภาพ วิเคราะห์ไทม์ไลน์ ตรวจจับสไปค์

---

## เริ่มต้นใช้งานอย่างรวดเร็ว

### 1. ติดตั้งเซิร์ฟเวอร์ MCP

```bash
uv tool install open-godot-mcp
# or
pip install open-godot-mcp
```

### 2. กำหนดค่าไคลเอนต์ AI

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. เปิดโปรเจกต์ Godot

แอดอนฉีดเข้าไปอัตโนมัติ เปิดไคลเอนต์ AI แล้วเริ่มใช้งานได้เลย

คู่มือติดตั้งฉบับเต็ม: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## รายการเครื่องมือ

ประมาณ 30 เครื่องมือ ประมาณ 130 การดำเนินการ ออกแบบแยกอ่าน/เขียน

| โดเมน | เครื่องมือ | คำอธิบาย |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | สถานะ ซีน การเลือก |
| Scene | `godot_scene` | สร้าง อ่าน บันทึก |
| Node | `godot_node_read/edit` | CRUD คุณสมบัติ กลุ่ม สัญญาณ |
| Script | `godot_script` | แก้ไขแบบ diff การตรวจสอบ |
| Project | `godot_project` | การตั้งค่า autoload |
| Input Map | `godot_input_map` | จัดการ InputMap |
| Resource | `godot_resource` | การตรวจสอบตามชนิด |
| Animation | `godot_animation` | สร้าง แทร็ก พรีเซ็ต |
| TileMap | `godot_tilemap` | อ่าน/เขียนเซลล์ |
| **ควบคุมเกม** | `godot_game` | เล่น/หยุด/หยุดนาฬิกา |
| **นาฬิกา** | `godot_game_time` | หยุด/ก้าน/ก้านจนครบเงื่อนไข |
| **อินพุต** | `godot_input` | คีย์บอร์ด/เมาส์/เกมแพด/ข้อความ |
| **สถานะ** | `godot_runtime_state` | สรุป/เฝ้าระวัง/สัญญาณ |
| **การฉีด** | `godot_exec` | eval/call/assert |
| สกรีนช็อต | `godot_screenshot` | บีบอัด บันทึกเป็นไฟล์ |
| ดีบักเกอร์ | `godot_debugger` | เบรกพอยต์ DAP, stack_trace, variables, evaluate |
| โค้ด | `godot_lsp` | การวินิจฉัย การเติมอัตโนมัติ |
| โพรไฟเลอร์ | `godot_profiler` | สแนปช็อต ไทม์ไลน์ |
| ทดสอบ | `godot_test` | เฟรมเวิร์ก การทำงาน |
| **เครือข่าย** | `godot_network` | หลายอินสแตนซ์ ซิงค์ สภาพเครือข่าย |
| อินสแตนซ์ | `godot_instance` | จัดการ Godot หลายตัว |
| ระบบไฟล์ | `godot_filesystem` | อ่าน/เขียน ค้นหา |
| เอกสาร | `godot_docs` | ตรงกับเวอร์ชัน |
| ล็อก | `godot_log` | คิวรีแบบเพิ่มทีละส่วน |
| กลุ่ม | `godot_batch` | หลายการดำเนินการพร้อมกัน |
| แอสเซ็ต | `godot_asset` | การสร้าง การจัดการ |
| ส่งออก | `godot_export` | พรีเซ็ต การส่งออก |
| สุขภาพ | `godot_health` | ตรวจสอบการเชื่อมต่อ |

API ฉบับเต็ม: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## เปรียบเทียบกับเซิร์ฟเวอร์ Godot MCP ที่มีอยู่

| ฟีเจอร์ | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| การดำเนินการเอดิเตอร์ | ✅ | ✅ | ✅ | ✅ | ✅ 149 เครื่องมือ | ✅ |
| ควบคุมเกมจริง | ⚠️ | ⚠️ | ❌ | ✅ กำหนดได้ | ⚠️ | ✅ **กำหนดได้+เรียลไทม์** |
| ทดสอบมัลติเพลเยอร์ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **ไม่ซ้ำใคร** |
| ดีบัก DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| ผสานรวม LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| ประสิทธิภาพโทเคน | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **ครบทุกด้าน** |
| ความเสถียรการเชื่อมต่อ | ⚠️ | ❌ | — | ✅ | — | ✅ **เสถียรที่สุด** |
| ลิขสิทธิ์ | เปิด | เปิด | MIT | MIT | MIT | **MIT** |

---

## คำถามที่พบบ่อย

### Model Context Protocol (MCP) คืออะไร?

[Model Context Protocol](https://modelcontextprotocol.io) คือมาตรฐานเปิดที่ให้ผู้ช่วย AI เชื่อมต่อกับเครื่องมือและแหล่งข้อมูลภายนอก Open Godot MCP คือเซิร์ฟเวอร์ MCP ที่เชื่อมต่อ AI เข้ากับเอดิเตอร์ Godot Engine

### รองรับ Godot เวอร์ชันใดบ้าง?

Godot 4.5 ขึ้นไป แอดอนใช้ API ของ Godot 4.x รวมถึง `EditorDebuggerPlugin`, `EditorInspector` และช่องสัญญาณดีบักเกอร์

### ไคลเอนต์ AI ใดใช้ได้บ้าง?

ไคลเอนต์ที่รองรับ MCP ใดๆ: Claude Desktop, Cursor, Windsurf, VS Code (พร้อมส่วนขยาย MCP), Continue, Zed และไคลเอนต์ที่รองรับมาตรฐาน Model Context Protocol

### รองรับ C# (เวอร์ชัน .NET ของ Godot) หรือไม่?

ใช่ รองรับการตรวจไวยากรณ์ C# และการยืนยันการคอมไพล์ ดู [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/)

### ต่างจากเซิร์ฟเวอร์ Godot MCP ตัวอื่นอย่างไร?

Open Godot MCP เป็น Godot MCP **เพียงตัวเดียว** ที่รองรับการทดสอบเกมมัลติเพลเยอร์ ผสานรวมดีบักเกอร์ DAP (เบรกพอยต์, stack trace, ตรวจตัวแปร) และความฉลาดโค้ด LSP พร้อมการออกแบบประหยัดโทเคนครบทุกด้านที่สุด

### ฟรีจริงไหม?

ใช่ สัญญาอนุญาต MIT 100% ไม่มีโมเดลฟรีเมียม ไม่มีกำแพงจ่ายเงิน ไม่มีการจำกัดฟีเจอร์ ฟีเจอร์ทุกอย่างฟรีสำหรับทุกคน

### AI เล่นเกมได้จริงหรือ?

ใช่ ผ่านการเล่นทดสอบแบบกำหนดได้ AI สามารถหยุดนาฬิกาเกม ก้านเวลาล่วงหน้าเป็นช่วงแม่นยำ ฉีดสถานการณ์ทดสอบ จำลองอินพุตผู้เล่น สังเกตสถานะเกมเป็น JSON และถ่ายสกรีนช็อต — เพื่อยืนยันว่าการเปลี่ยนแปลงโค้ดทำงานถูกต้อง

### การทดสอบมัลติเพลเยอร์ทำงานอย่างไร?

Open Godot MCP สามารถเปิดอินสแตนซ์ Godot หลายตัว (host + client) จำลอง peer ฉีดสภาพเครือข่าย (ความหน่วง การสูญเสียแพ็กเก็ต) และยืนยันว่าสถานะเกมซิงค์กันข้ามอินสแตนซ์

---

## เอกสาร

ดัชนีเอกสารฉบับเต็ม: [Docs/README.md](Docs/README.md). แยกตามโฟลเดอร์

| โฟลเดอร์ | เนื้อหา |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | ภาพรวมฟีเจอร์ ปรัชญาการออกแบบ |
| [Docs/01-Architecture/](Docs/01-Architecture/) | สถาปัตยกรรม โปรโตคอล ความเสถียรการเชื่อมต่อ หลายอินสแตนซ์ รันไทม์ |
| [Docs/02-Tools/](Docs/02-Tools/) | รายการเครื่องมือครบถ้วน (ไฟล์แยกตามโดเมน) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | การเล่นทดสอบแบบกำหนดได้ (คู่มือ + ตัวอย่าง) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | การออกแบบประหยัดโทเคน (คู่มือ + กลยุทธ์) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | การทดสอบมัลติเพลเยอร์ (คู่มือ + ตัวอย่าง) |
| [Docs/06-Installation/](Docs/06-Installation/) | การติดตั้ง (คู่มือ + การแก้ไขปัญหา) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | แผนพัฒนา |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | ความเข้ากันได้ของ C# Godot และการตรวจไวยากรณ์ |
| [Docs/09-Research/](Docs/09-Research/) | งานวิจัย MCP ที่มีอยู่ งานวิจัย C# MCP |

---

## กิตติกรรมประกาศ

Open Godot MCP ยืนอยู่บนไหล่ผู้ยิ่งใหญ่ โดยนำส่วนที่ดีที่สุดมาจาก:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k stars) — สถาปัตยกรรมพื้นฐาน
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — การเล่นทดสอบแบบกำหนดได้ การสังเกตราคาถูก การแยกอ่าน/เขียน
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — รันไทม์ช่องดีบักเกอร์ Undo/Redo การจองพอร์ต Windows คอนฟิกไคลเอนต์ 20+ McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — สถาปัตยกรรมดูอัลแชนเนล การทำให้ Variant เป็นอนุกรม การป้องกันการลบ
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — ผสานรวม DAP + LSP หลายอินสแตนซ์ การแยกพอร์ต
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — ไม่มีรอยเท้า แนวคิด Playwright สำหรับ Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — ข้อมูลอ้างอิงความกว้างขวาง 149 เครื่องมือ

---

## ลิขสิทธิ์

[MIT](LICENSE) — โอเพนซอร์ส 100% ฟีเจอร์ทุกอย่างฟรี ไม่มีฟรีเมียม ไม่มีกำแพงจ่ายเงิน
