<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI 기반 Godot 게임 개발, 테스트 및 디버깅
@description: AI 자율 Godot 게임 개발을 위한 오픈소스 MCP 서버. 결정론적 플레이테스트, 멀티플레이어 테스트, DAP 디버깅, LSP 통합, 토큰 효율성. 100% MIT.
@keywords: godot mcp, model context protocol, ai game development, godot ai, game testing, playtesting, deterministic testing, multiplayer testing, game debugging, dap debugger, lsp integration, gdscript, godot 4, open source mcp, ai coding assistant, claude mcp, game engine ai, automated game testing, godot plugin, token efficiency
@author: MasterYee Labs
@language: ko
@og:type: software
@og:title: Open Godot MCP
@og:description: AI 기반 Godot 게임 개발을 위한 오픈소스 MCP 서버 — 결정론적 플레이테스트, 멀티플레이어 테스트, DAP 디버깅, LSP, 토큰 효율성.
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
  "description": "AI 자율 Godot 게임 개발, 테스트, 디버깅을 위한 오픈소스 Model Context Protocol 서버. 결정론적 플레이테스트, 멀티플레이어 테스트, DAP 디버깅, LSP 통합, 토큰 효율적 설계를 제공합니다.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "결정론적 플레이테스트 (freeze/step/step_until)",
    "멀티플레이어 게임 테스트 (멀티 인스턴스, 피어 시뮬레이션)",
    "DAP 디버깅 (중단점, stack_trace, variables, evaluate)",
    "LSP 통합 (진단, 자동완성, 정의로 이동)",
    "토큰 효율적 설계 (JSON 요약, diff, 스크린샷 압축)",
    "30+ MCP 도구, 130+ 액션",
    "연결 안정성 (하트비트, 스마트 재연결, 포트 자동 회피)"
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

> 오픈소스이며 무료인, 모든 기능을 갖춘 Model Context Protocol (MCP) 서버. AI가 자율적으로 Godot 게임을 개발, 테스트, 디버깅할 수 있게 해줍니다 — 실제 게임 제어, 결정론적 플레이테스트, 멀티플레이어 테스트, DAP 디버깅, LSP 통합, 토큰 효율성 설계까지 내장되어 있습니다. 100% MIT 라이선스, 프리미엄 제한 없음, 페이월 없음.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP란?

**Open Godot MCP**는 AI 코딩 어시스턴트(Claude, GPT, Cursor, Windsurf 등)를 [Godot Engine](https://godotengine.org) 에디터에 연결하는 오픈소스 [Model Context Protocol](https://modelcontextprotocol.io) 서버입니다. AI가 **코드 작성, 게임 실행, 게임플레이 테스트, 중단점 디버깅, 변수 검사, 수정 사항 검증**을 모두 자율적으로, 인간 개입 없이 수행할 수 있게 해줍니다.

씬 편집만 하는 기존 Godot MCP 서버와 달리, Open Godot MCP는 AI가 결정론적 플레이테스트(클록 정지 → 시간 스텝 → 상태 관측 → 결과 검증)를 통해 **직접 게임을 플레이**할 수 있게 합니다. **멀티플레이어 게임 테스트**, **DAP 디버거 통합**, **LSP 코드 인텔리전스**를 지원하는 **유일한** Godot MCP입니다.

| 속성 | 값 |
|-----------|-------|
| **프로젝트 유형** | Godot Engine용 MCP 서버 (Model Context Protocol) |
| **대상 엔진** | Godot 4.5+ (GDScript + C# 지원) |
| **런타임** | Python 3.11+ (서버) + GDScript (애드온) |
| **라이선스** | MIT (100% 오픈소스, 프리미엄 제한 없음) |
| **도구** | 약 30개 MCP 도구, 약 130개 액션 |
| **핵심 기능** | 결정론적 플레이테스트, 멀티플레이어 테스트, DAP 디버깅, LSP, 토큰 효율성 |
| **AI 클라이언트** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, MCP 호환 클라이언트 |
| **플랫폼** | Windows, macOS, Linux |
| **독자적 기능** | 멀티플레이어 테스트 (다른 Godot MCP에는 없음), DAP + LSP 통합 |

---

## 이 프로젝트가 존재하는 이유

시중의 모든 Godot MCP에는 단점이 있습니다:

| 문제 | 기존 MCP | Open Godot MCP |
|---------|--------------|-----------------|
| AI가 게임이 실제로 실행되는 것을 볼 수 없음 | 편집 전용, 버그를 수정하려 게임을 플레이할 수 없음 | **결정론적 플레이테스트** — 클록 정지, 정밀 시간 스텝, step_until 조건 |
| 불안정한 연결 | 포트 고정, 하트비트 없음, WSL2 충돌 | 포트 설정 가능 + 하트비트 + 스마트 재연결 + 포트 자동 회피 |
| 멀티플레이어 테스트 불가 | 모든 MCP에 멀티플레이어 테스트 부재 | **유일** — 멀티 인스턴스, 피어 시뮬레이션, 동기화 검증, 네트워크 조건 주입 |
| 토큰 낭비 | 전체 반환, 압축 없는 PNG, diff 없음 | 저비용 관측, 스크린샷 압축, diff, 요약, 점진적 쿼리 |
| 프리미엄 기능 제한 | 무료 버전 제한, 기능마다 유료 결제 | **100% MIT 오픈소스**, 모든 기능 무료 |

---

## 대상 독자

- **Godot 4를 사용하는 게임 개발자** — AI가 게임 작성, 테스트, 디버깅을 도와주길 원하는
- **AI 보조 코더** (Claude, Cursor, Windsurf, VS Code MCP 사용자) — Godot 프로젝트 작업 중인
- **인디 게임 스튜디오** — 테스트 프레임워크 작성 없이 자동 플레이테스트가 필요한
- **멀티플레이어 게임 개발자** — 네트워크 동기화, 지연, 피어 동작을 테스트해야 하는
- **오픈소스 옹호자** — 페이월 없는 완전 무료 MCP 서버를 원하는

---

## 사용 사례

| 사용 사례 | Open Godot MCP의 도움 |
|----------|--------------------------|
| **AI가 이동 버그 수정** | AI가 중단점 설정 → 게임 실행 → 변수 검사 → 근본 원인 식별 → 코드 수정 → 재테스트 |
| **보스전 자동 테스트** | 클록 정지 → 보스 스폰 → 시간 스텝 → 회피 입력 시뮬레이션 → 플레이어 생존 검증 |
| **멀티플레이어 동기화 검증** | 호스트 + 클라이언트 인스턴스 실행 → 지연 주입 → 동기화 상태 비교 → 디싱크 버그 탐지 |
| **성능 프로파일링** | 프로파일러 스냅샷 → 스파이크 식별 → 최적화 → 재측정 |
| **회귀 테스트** | 코드 변경 후 테스트 스위트 실행 → 게임 상태가 예상과 일치하는지 확인 |
| **레벨 디자인 반복** | AI가 노드 생성 → 씬 배치 → 게임 실행 → 결과 스크린샷 → 조정 |

---

## 핵심 기능

### 1. 결정론적 플레이테스트 ("AI가 게임 실행을 볼 수 없다" 해결)

AI는 코드만 작성하지 않습니다 — **직접 게임을 플레이하여 수정 사항을 검증**할 수 있습니다:

```
godot_game play frozen=true                    # 게임 실행 (클록 정지)
godot_exec eval code="GameState.wave = 3"      # 테스트 시나리오 설정
godot_game_time step_until "boss.size() >= 1"  # 보스 등장 대기
godot_runtime_state digest                     # 상태 관측 (JSON, 비전 토큰 없음)
godot_game_time step ms=500 + dodge input      # 결정적 순간 플레이
godot_screenshot game                          # 가치 있을 때만 스크린샷
```

### 2. 멀티플레이어 테스트 (유일한 기능 — 다른 Godot MCP에는 없음)

기존 어떤 Godot MCP에도 없는 기능입니다:

```
godot_network launch_instance role="host"      # 서버 시작
godot_network launch_instance role="client"    # 클라이언트 시작
godot_network network_condition latency=200    # 200ms 지연 주입
godot_network sync_state                       # 멀티 인스턴스 동기화 검증
godot_network simulate_peer count=50           # 50개 피어 부하 테스트
```

### 3. 토큰 효율성

모든 도구에 토큰 절약 설계가 적용되어 있습니다:

- **저비용 관측**: JSON 상태 요약이 스크린샷을 대체 (토큰 90% 절약)
- **diff 반환**: 변경된 부분만 반환
- **스크린샷 압축**: JPEG/WebP + 디스크 저장 (컨텍스트에 보관하지 않음)
- **읽기/쓰기 분리**: 읽기는 자동 허용, 쓰기는 제어
- **배치 작업**: 한 번의 왕복으로 여러 작업 완료

### 4. 연결 안정성

기존 MCP의 "연결 안 됨" 문제를 해결합니다:

- 포트 설정 가능 (환경변수 > EditorSettings > 자동 회피)
- Windows 포트 예약 감지 (Hyper-V/WSL2/Docker 예약 포트 회피)
- 하트비트 메커니즘 (능동적 끊긴 연결 감지)
- 스마트 재연결 (지수 백오프 + 최대 재시도 + UI 알림)

### 5. 완전한 디버깅

- **DAP (Debugger Adapter Protocol)**: 중단점, 스텝, 변수 검사 (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: 정적 진단, 자동완성, 정의로 이동
- **프로파일러**: 성능 스냅샷, 타임라인 분석, 스파이크 감지

---

## 빠른 시작

### 1. MCP 서버 설치

```bash
uv tool install open-godot-mcp
# 또는
pip install open-godot-mcp
```

### 2. AI 클라이언트 설정

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot 프로젝트 열기

애드온이 자동으로 주입됩니다. AI 클라이언트를 열고 사용을 시작하세요.

전체 설치 가이드: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## 도구 목록

약 30개 도구, 약 130개 액션. 읽기/쓰기 분리 설계.

| 도메인 | 도구 | 설명 |
|--------|------|-------------|
| 에디터 | `godot_editor_read/edit` | 상태, 씬, 선택 |
| 씬 | `godot_scene` | 생성, 읽기, 저장 |
| 노드 | `godot_node_read/edit` | CRUD, 속성, 그룹, 시그널 |
| 스크립트 | `godot_script` | diff 편집, 검증 |
| 프로젝트 | `godot_project` | 설정, 오토로드 |
| 입력 맵 | `godot_input_map` | InputMap 관리 |
| 리소스 | `godot_resource` | 타입 인식 검사 |
| 애니메이션 | `godot_animation` | 생성, 트랙, 프리셋 |
| TileMapLayer | `godot_tilemap` | 셀 읽기/쓰기 |
| **게임 제어** | `godot_game` | play/stop/freeze |
| **클록** | `godot_game_time` | freeze/step/step_until |
| **입력** | `godot_input` | 키보드/마우스/게임패드/텍스트 |
| **상태** | `godot_runtime_state` | digest/watch/signals |
| **주입** | `godot_exec` | eval/call/assert |
| 스크린샷 | `godot_screenshot` | 압축, 파일 저장 |
| 디버거 | `godot_debugger` | DAP 중단점, stack_trace, variables, evaluate |
| 코드 | `godot_lsp` | 진단, 완성 |
| 프로파일러 | `godot_profiler` | 스냅샷, 타임라인 |
| 테스트 | `godot_test` | 프레임워크, 실행 |
| **네트워크** | `godot_network` | 멀티 인스턴스, 동기화, 네트워크 조건 |
| 인스턴스 | `godot_instance` | 멀티 Godot 관리 |
| 파일시스템 | `godot_filesystem` | 읽기/쓰기, 검색 |
| 문서 | `godot_docs` | 버전 일치 |
| 로그 | `godot_log` | 점진적 쿼리 |
| 배치 | `godot_batch` | 여러 작업 동시 처리 |
| 에셋 | `godot_asset` | 생성, 관리 |
| 내보내기 | `godot_export` | 프리셋, 내보내기 |
| 헬스 | `godot_health` | 연결 확인 |

전체 API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## 기존 Godot MCP 서버와의 비교

| 기능 | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| 에디터 작업 | ✅ | ✅ | ✅ | ✅ | ✅ 149개 도구 | ✅ |
| 실제 게임 제어 | ⚠️ | ⚠️ | ❌ | ✅ 결정론적 | ⚠️ | ✅ **결정론적+실시간** |
| 멀티플레이어 테스트 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **유일** |
| DAP 디버깅 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP 통합 | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| 토큰 효율성 | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **종합적** |
| 연결 안정성 | ⚠️ | ❌ | — | ✅ | — | ✅ **가장 안정적** |
| 라이선스 | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Model Context Protocol (MCP)란 무엇인가요?

[Model Context Protocol](https://modelcontextprotocol.io)은 AI 어시스턴트가 외부 도구와 데이터 소스에 연결할 수 있게 해주는 개방형 표준입니다. Open Godot MCP는 AI를 Godot Engine 에디터에 연결하는 MCP 서버입니다.

### 어떤 Godot 버전을 지원하나요?

Godot 4.5 이상을 지원합니다. 애드온은 `EditorDebuggerPlugin`, `EditorInspector`, 디버거 메시지 채널을 포함한 Godot 4.x API를 사용합니다.

### 어떤 AI 클라이언트와 호환되나요?

MCP 호환 클라이언트라면 모두 호환됩니다: Claude Desktop, Cursor, Windsurf, VS Code (MCP 확장 포함), Continue, Zed, 그리고 Model Context Protocol 표준을 지원하는 모든 클라이언트.

### C# (Godot의 .NET 버전)을 지원하나요?

네. C# 구문 검사와 컴파일 검증을 지원합니다. [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/)를 참조하세요.

### 다른 Godot MCP 서버와 어떻게 다른가요?

Open Godot MCP는 멀티플레이어 게임 테스트, DAP 디버거 통합(중단점, 스택 트레이스, 변수 검사), LSP 코드 인텔리전스를 지원하는 **유일한** Godot MCP입니다. 또한 가장 종합적인 토큰 효율성 설계를 갖추고 있습니다.

### 정말 무료인가요?

네. 100% MIT 라이선스, 프리미엄 모델 없음, 페이월 없음, 기능 제한 없음. 모든 기능이 모두에게 무료입니다.

### AI가 실제로 게임을 플레이할 수 있나요?

네. 결정론적 플레이테스트를 통해 AI가 게임 클록을 정지하고, 정밀한 단위로 시간을 스텝하고, 테스트 시나리오를 주입하고, 플레이어 입력을 시뮬레이션하고, 게임 상태를 JSON으로 관측하고, 스크린샷을 캡처할 수 있습니다 — 모두 코드 변경이 올바르게 작동하는지 검증하기 위함입니다.

### 멀티플레이어 테스트는 어떻게 작동하나요?

Open Godot MCP는 여러 Godot 인스턴스(호스트 + 클라이언트)를 실행하고, 피어를 시뮬레이션하고, 네트워크 조건(지연, 패킷 손실)을 주입하고, 게임 상태가 인스턴스 간에 동기화되는지 검증할 수 있습니다.

---

## 문서

전체 문서 인덱스: [Docs/README.md](Docs/README.md). 폴더별로 분리되어 있습니다.

| 폴더 | 내용 |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | 기능 개요, 설계 철학 |
| [Docs/01-Architecture/](Docs/01-Architecture/) | 아키텍처, 프로토콜, 연결 안정성, 멀티 인스턴스, 런타임 |
| [Docs/02-Tools/](Docs/02-Tools/) | 전체 도구 목록 (도메인별 파일) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | 결정론적 플레이테스트 (가이드 + 예제) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | 토큰 절약 설계 (가이드 + 전략) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | 멀티플레이어 테스트 (가이드 + 예제) |
| [Docs/06-Installation/](Docs/06-Installation/) | 설치 (가이드 + 문제 해결) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | 개발 로드맵 |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot 호환성 & 구문 검사 |
| [Docs/09-Research/](Docs/09-Research/) | 기존 MCP 연구, C# MCP 연구 |

---

## 감사의 말

Open Godot MCP는 거인의 어깨 위에 서 있으며, 다음으로부터 최선을 취했습니다:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k 스타) — 기반 아키텍처
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — 결정론적 플레이테스트, 저비용 관측, 읽기/쓰기 분리
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — 디버거 채널 런타임, Undo/Redo, Windows 포트 예약, 20+ 클라이언트 설정, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — 듀얼 채널 아키텍처, Variant 직렬화, 삭제 보호
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP 통합, 멀티 인스턴스, 포트 격리
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — 제로 풋프린트, Godot용 Playwright 개념
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149개 도구 폭 참조

---

## 라이선스

[MIT](LICENSE) — 100% 오픈소스, 모든 기능 무료, 프리미엄 제한 없음, 페이월 없음.
