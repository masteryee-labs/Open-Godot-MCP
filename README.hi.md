<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI-संचालित Godot गेम विकास, परीक्षण और डिबगिंग
@description: AI-स्वायत्त Godot गेम विकास के लिए ओपन-सोर्स MCP सर्वर। नियतात्मक प्लेटेस्टिंग, मल्टीप्लेयर परीक्षण, DAP डिबगिंग, LSP एकीकरण, टोकन-दक्ष। 100% MIT।
@keywords: godot mcp, model context protocol, ai game development, godot ai, game testing, playtesting, deterministic testing, multiplayer testing, game debugging, dap debugger, lsp integration, gdscript, godot 4, open source mcp, ai coding assistant, claude mcp, game engine ai, automated game testing, godot plugin, token efficiency
@author: MasterYee Labs
@language: hi
@og:type: software
@og:title: Open Godot MCP
@og:description: AI-संचालित Godot गेम विकास के लिए ओपन-सोर्स MCP सर्वर — नियतात्मक प्लेटेस्टिंग, मल्टीप्लेयर परीक्षण, DAP डिबगिंग, LSP, टोकन-दक्ष।
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
  "description": "AI-स्वायत्त Godot गेम विकास, परीक्षण और डिबगिंग के लिए ओपन-सोर्स Model Context Protocol सर्वर। इसमें नियतात्मक प्लेटेस्टिंग, मल्टीप्लेयर परीक्षण, DAP डिबगिंग, LSP एकीकरण और टोकन-दक्ष डिज़ाइन शामिल हैं।",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "नियतात्मक प्लेटेस्टिंग (freeze/step/step_until)",
    "मल्टीप्लेयर गेम परीक्षण (मल्टी-इंस्टेंस, पीयर सिमुलेशन)",
    "DAP डिबगिंग (ब्रेकपॉइंट, stack_trace, variables, evaluate)",
    "LSP एकीकरण (निदान, ऑटोकम्प्लीशन, गो-टू-डेफिनिशन)",
    "टोकन-दक्ष डिज़ाइन (JSON डाइजेस्ट, डिफ, स्क्रीनशॉट संपीड़न)",
    "30+ MCP उपकरण, 130+ क्रियाएँ",
    "कनेक्शन स्थिरता (हार्टबीट, स्मार्ट पुनःकनेक्ट, पोर्ट स्वतः-परिहार)"
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

> ओपन-सोर्स, मुफ़्त, पूर्ण-विशेषताओं वाला Model Context Protocol (MCP) सर्वर जो AI को स्वायत्त रूप से Godot गेम विकसित करने, परीक्षण करने और डिबग करने देता है — जिसमें वास्तविक गेम नियंत्रण, नियतात्मक प्लेटेस्टिंग, मल्टीप्लेयर परीक्षण, DAP डिबगिंग, LSP एकीकरण और टोकन-दक्ष डिज़ाइन शामिल हैं। 100% MIT लाइसेंस, कोई फ्रीमियम नहीं, कोई पेवॉल नहीं।

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**भाषाएँ:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP क्या है?

**Open Godot MCP** एक ओपन-सोर्स [Model Context Protocol](https://modelcontextprotocol.io) सर्वर है जो AI कोडिंग सहायकों (Claude, GPT, Cursor, Windsurf, आदि) को [Godot Engine](https://godotengine.org) एडिटर से जोड़ता है। यह AI को **कोड लिखने, गेम चलाने, गेमप्ले परीक्षण करने, ब्रेकपॉइंट पर डिबग करने, वेरिएबल निरीक्षण करने और सुधार सत्यापित करने** में सक्षम बनाता है — सब स्वायत्त रूप से, मानवीय हस्तक्षेप के बिना।

मौजूदा Godot MCP सर्वर जो केवल दृश्य संपादित करते हैं, उनसे भिन्न, Open Godot MCP AI को **वास्तव में गेम खेलने** देता है नियतात्मक प्लेटेस्टिंग के माध्यम से (घड़ी जमाएँ → समय कदम → स्थिति अवलोकन → परिणाम सत्यापित करें)। यह **एकमात्र** Godot MCP है जो **मल्टीप्लेयर गेम परीक्षण**, **DAP डिबगर एकीकरण** और **LSP कोड बुद्धिमत्ता** का समर्थन करता है।

| विशेषता | मान |
|-----------|-------|
| **प्रोजेक्ट प्रकार** | Godot Engine के लिए MCP सर्वर (Model Context Protocol) |
| **लक्षित इंजन** | Godot 4.5+ (GDScript + C# समर्थन) |
| **रनटाइम** | Python 3.11+ (सर्वर) + GDScript (ऐडऑन) |
| **लाइसेंस** | MIT (100% ओपन सोर्स, कोई फ्रीमियम नहीं) |
| **उपकरण** | ~30 MCP उपकरण, ~130 क्रियाएँ |
| **मुख्य विशेषताएँ** | नियतात्मक प्लेटेस्टिंग, मल्टीप्लेयर परीक्षण, DAP डिबगिंग, LSP, टोकन दक्षता |
| **AI क्लाइंट** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, कोई भी MCP-संगत क्लाइंट |
| **प्लेटफ़ॉर्म** | Windows, macOS, Linux |
| **अद्वितीय क्षमताएँ** | मल्टीप्लेयर परीक्षण (किसी अन्य Godot MCP में नहीं), DAP + LSP एकीकरण |

---

## यह क्यों बनाया गया

बाज़ार में उपलब्ध हर Godot MCP में कुछ न कुछ कमियाँ हैं:

| समस्या | मौजूदा MCP | Open Godot MCP |
|---------|--------------|-----------------|
| AI गेम को वास्तव में चलते हुए नहीं देख सकता | केवल संपादन, बग ठीक करने के लिए गेम नहीं चला सकता | **नियतात्मक प्लेटेस्टिंग** — घड़ी जमाएँ, सटीक समय कदम, step_until शर्त |
| अस्थिर कनेक्शन | हार्डकोडेड पोर्ट, कोई हार्टबीट नहीं, WSL2 टकराव | विन्यास योग्य पोर्ट + हार्टबीट + स्मार्ट पुनःकनेक्ट + पोर्ट स्वतः-परिहार |
| मल्टीप्लेयर परीक्षण नहीं कर सकता | सभी MCP में मल्टीप्लेयर परीक्षण की कमी | **अद्वितीय** — मल्टी-इंस्टेंस, पीयर सिमुलेशन, सिंक सत्यापन, नेटवर्क स्थिति इंजेक्शन |
| टोकन बर्बादी | पूर्ण रिटर्न, असंपीड़ित PNG, कोई डिफ नहीं | सस्ती अवलोकन, स्क्रीनशॉट संपीड़न, डिफ, सारांश, वृद्धिशील क्वेरी |
| फ्रीमियम प्रतिबंध | मुफ़्त संस्करण सीमित, सुविधाओं के लिए भुगतान करें | **100% MIT ओपन सोर्स**, सभी सुविधाएँ मुफ़्त |

---

## यह किसके लिए है?

- **Godot 4 का उपयोग करने वाले गेम डेवलपर** जो चाहते हैं कि AI उनके गेम लिखने, परीक्षण करने और डिबग करने में मदद करे
- **AI-सहायित कोडर** (Claude, Cursor, Windsurf, VS Code MCP उपयोगकर्ता) जो Godot प्रोजेक्ट पर काम कर रहे हैं
- **इंडी गेम स्टूडियो** जिन्हें टेस्ट फ्रेमवर्क लिखे बिना स्वचालित प्लेटेस्टिंग चाहिए
- **मल्टीप्लेयर गेम डेवलपर** जिन्हें नेटवर्क सिंक, विलंबता और पीयर व्यवहार परीक्षण करना है
- **ओपन-सोर्स वक्ता** जो बिना पेवॉल के पूरी तरह मुफ़्त MCP सर्वर चाहते हैं

---

## उपयोग के मामले

| उपयोग का मामला | Open Godot MCP कैसे मदद करता है |
|----------|--------------------------|
| **AI मूवमेंट बग ठीक करता है** | AI ब्रेकपॉइंट लगाता है → गेम चलाता है → वेरिएबल निरीक्षण करता है → मूल कारण पहचानता है → कोड ठीक करता है → पुनः परीक्षण करता है |
| **स्वचालित बॉस फाइट परीक्षण** | घड़ी जमाएँ → बॉस स्पॉन करें → समय कदम → डॉज इनपुट सिमुलेट करें → खिलाड़ी के जीवित रहने की पुष्टि करें |
| **मल्टीप्लेयर सिंक सत्यापन** | होस्ट + क्लाइंट इंस्टेंस लॉन्च करें → विलंबता इंजेक्ट करें → सिंक स्थिति तुलना करें → डिसिंक बग पहचानें |
| **प्रदर्शन प्रोफाइलिंग** | प्रोफाइलर स्नैपशॉट लें → स्पाइक पहचानें → अनुकूलन करें → पुनः मापें |
| **रिग्रेशन परीक्षण** | कोड परिवर्तन के बाद टेस्ट सूट चलाएँ → गेम स्थिति की अपेक्षित मान से मिलान की पुष्टि करें |
| **लेवल डिज़ाइन पुनरावृत्ति** | AI नोड बनाता है → दृश्य व्यवस्थित करता है → गेम चलाता है → परिणाम स्क्रीनशॉट करता है → समायोजन करता है |

---

## मुख्य क्षमताएँ

### 1. नियतात्मक प्लेटेस्टिंग ("AI गेम को चलते हुए नहीं देख सकता" का समाधान)

AI केवल कोड नहीं लिखता — यह **सुधार सत्यापित करने के लिए स्वयं गेम खेल सकता है**:

```
godot_game play frozen=true                    # गेम लॉन्च करें (जमी हुई घड़ी)
godot_exec eval code="GameState.wave = 3"      # परीक्षण परिदृश्य सेट करें
godot_game_time step_until "boss.size() >= 1"  # बॉस के प्रकट होने की प्रतीक्षा करें
godot_runtime_state digest                     # स्थिति अवलोकन (JSON, कोई विज़न टोकन नहीं)
godot_game_time step ms=500 + dodge input      # महत्वपूर्ण क्षण खेलें
godot_screenshot game                          # केवल तभी स्क्रीनशॉट जब आवश्यक हो
```

### 2. मल्टीप्लेयर परीक्षण (अद्वितीय सुविधा — किसी अन्य Godot MCP में नहीं)

एक क्षमता जो किसी भी मौजूदा Godot MCP में नहीं है:

```
godot_network launch_instance role="host"      # सर्वर प्रारंभ करें
godot_network launch_instance role="client"    # क्लाइंट प्रारंभ करें
godot_network network_condition latency=200    # 200ms विलंबता इंजेक्ट करें
godot_network sync_state                       # मल्टी-इंस्टेंस सिंक सत्यापित करें
godot_network simulate_peer count=50           # 50 पीयर स्ट्रेस परीक्षण
```

### 3. टोकन दक्षता

हर उपकरण में टोकन-बचत डिज़ाइन है:

- **सस्ती अवलोकन**: JSON स्थिति डाइजेस्ट स्क्रीनशॉट की जगह (90% टोकन बचत)
- **डिफ रिटर्न**: केवल बदले हुए हिस्से लौटाएँ
- **स्क्रीनशॉट संपीड़न**: JPEG/WebP + डिस्क पर सहेजें (संदर्भ में नहीं)
- **पढ़ने/लिखने का पृथक्करण**: पढ़ना स्वतः-अनुमत, लिखना नियंत्रित
- **बैच संक्रियाएँ**: एक राउंड-ट्रिप में कई संक्रियाएँ पूर्ण करें

### 4. कनेक्शन स्थिरता

मौजूदा MCP में "कनेक्ट नहीं हो सकता" समस्या का समाधान:

- विन्यास योग्य पोर्ट (env > EditorSettings > स्वतः-परिहार)
- Windows पोर्ट आरक्षण पहचान (Hyper-V/WSL2/Docker आरक्षित पोर्ट से बचें)
- हार्टबीट तंत्र (सक्रिय मृत-कनेक्शन पहचान)
- स्मार्ट पुनःकनेक्ट (घातीय बैकऑफ़ + अधिकतम पुनःप्रयास + UI सूचना)

### 5. संपूर्ण डिबगिंग

- **DAP (Debugger Adapter Protocol)**: ब्रेकपॉइंट, स्टेपिंग, वेरिएबल निरीक्षण (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: स्थैतिक निदान, ऑटोकम्प्लीशन, गो-टू-डेफिनिशन
- **प्रोफाइलर**: प्रदर्शन स्नैपशॉट, टाइमलाइन विश्लेषण, स्पाइक पहचान

---

## त्वरित प्रारंभ

### 1. MCP सर्वर स्थापित करें

```bash
uv tool install open-godot-mcp
# या
pip install open-godot-mcp
```

### 2. AI क्लाइंट विन्यस्त करें

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot प्रोजेक्ट खोलें

ऐडऑन स्वतः-इंजेक्ट होता है। अपना AI क्लाइंट खोलें और उपयोग शुरू करें।

पूर्ण स्थापना गाइड: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md)।

---

## उपकरण सूची

~30 उपकरण, ~130 क्रियाएँ। पढ़ने/लिखने पृथक्करण डिज़ाइन।

| डोमेन | उपकरण | विवरण |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | स्थिति, दृश्य, चयन |
| Scene | `godot_scene` | बनाएँ, पढ़ें, सहेजें |
| Node | `godot_node_read/edit` | CRUD, गुण, समूह, सिग्नल |
| Script | `godot_script` | डिफ संपादन, सत्यापन |
| Project | `godot_project` | सेटिंग्स, ऑटोलोड |
| Input Map | `godot_input_map` | InputMap प्रबंधन |
| Resource | `godot_resource` | प्रकार-जागरूक निरीक्षण |
| Animation | `godot_animation` | बनाएँ, ट्रैक, प्रीसेट |
| TileMap | `godot_tilemap` | सेल पढ़ें/लिखें |
| **गेम नियंत्रण** | `godot_game` | play/stop/freeze |
| **घड़ी** | `godot_game_time` | freeze/step/step_until |
| **इनपुट** | `godot_input` | कीबोर्ड/माउस/गेमपैड/टेक्स्ट |
| **स्थिति** | `godot_runtime_state` | digest/watch/signals |
| **इंजेक्शन** | `godot_exec` | eval/call/assert |
| स्क्रीनशॉट | `godot_screenshot` | संपीड़न, फ़ाइल में सहेजें |
| डिबगर | `godot_debugger` | DAP ब्रेकपॉइंट, stack_trace, variables, evaluate |
| कोड | `godot_lsp` | निदान, कम्प्लीशन |
| प्रोफाइलर | `godot_profiler` | स्नैपशॉट, टाइमलाइन |
| परीक्षण | `godot_test` | फ्रेमवर्क, निष्पादन |
| **नेटवर्क** | `godot_network` | मल्टी-इंस्टेंस, सिंक, नेटवर्क स्थितियाँ |
| इंस्टेंस | `godot_instance` | मल्टी-Godot प्रबंधन |
| फाइलसिस्टम | `godot_filesystem` | पढ़ें/लिखें, खोज |
| डॉक्स | `godot_docs` | संस्करण-मिलान |
| लॉग | `godot_log` | वृद्धिशील क्वेरी |
| बैच | `godot_batch` | एक साथ कई संक्रियाएँ |
| एसेट | `godot_asset` | जनरेशन, प्रबंधन |
| निर्यात | `godot_export` | प्रीसेट, निर्यात |
| स्वास्थ्य | `godot_health` | कनेक्शन जाँच |

पूर्ण API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md)।

---

## मौजूदा Godot MCP सर्वर के साथ तुलना

| सुविधा | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Editor संक्रियाएँ | ✅ | ✅ | ✅ | ✅ | ✅ 149 उपकरण | ✅ |
| वास्तविक गेम नियंत्रण | ⚠️ | ⚠️ | ❌ | ✅ नियतात्मक | ⚠️ | ✅ **नियतात्मक+वास्तविक-समय** |
| मल्टीप्लेयर परीक्षण | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **अद्वितीय** |
| DAP डिबगिंग | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP एकीकरण | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| टोकन दक्षता | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **व्यापक** |
| कनेक्शन स्थिरता | ⚠️ | ❌ | — | ✅ | — | ✅ **सबसे स्थिर** |
| लाइसेंस | open | open | MIT | MIT | MIT | **MIT** |

---

## अक्सर पूछे जाने वाले प्रश्न (FAQ)

### Model Context Protocol (MCP) क्या है?

[Model Context Protocol](https://modelcontextprotocol.io) एक ओपन मानक है जो AI सहायकों को बाहरी उपकरणों और डेटा स्रोतों से जोड़ने देता है। Open Godot MCP एक MCP सर्वर है जो AI को Godot Engine एडिटर से जोड़ता है।

### कौन से Godot संस्करण समर्थित हैं?

Godot 4.5 और नए। ऐडऑन Godot 4.x API का उपयोग करता है जिसमें `EditorDebuggerPlugin`, `EditorInspector` और डिबगर संदेश चैनल शामिल हैं।

### कौन से AI क्लाइंट संगत हैं?

कोई भी MCP-संगत क्लाइंट: Claude Desktop, Cursor, Windsurf, VS Code (MCP एक्सटेंशन के साथ), Continue, Zed, और कोई भी क्लाइंट जो Model Context Protocol मानक का समर्थन करता है।

### क्या यह C# (Godot का .NET संस्करण) का समर्थन करता है?

हाँ। C# सिंटैक्स जाँच और कंपाइल सत्यापन समर्थित हैं। देखें [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/)।

### यह अन्य Godot MCP सर्वरों से कैसे भिन्न है?

Open Godot MCP **एकमात्र** Godot MCP है जो मल्टीप्लेयर गेम परीक्षण, DAP डिबगर एकीकरण (ब्रेकपॉइंट, स्टैक ट्रेस, वेरिएबल निरीक्षण) और LSP कोड बुद्धिमत्ता का समर्थन करता है। इसमें सबसे व्यापक टोकन-दक्षता डिज़ाइन भी है।

### क्या यह सच में मुफ़्त है?

हाँ। 100% MIT लाइसेंस, कोई फ्रीमियम मॉडल नहीं, कोई पेवॉल नहीं, कोई सुविधा बाधा नहीं। सभी सुविधाएँ सभी के लिए मुफ़्त हैं।

### क्या AI वास्तव में गेम खेल सकता है?

हाँ। नियतात्मक प्लेटेस्टिंग के माध्यम से, AI गेम घड़ी जमा सकता है, समय को सटीक वृद्धि में आगे बढ़ा सकता है, परीक्षण परिदृश्य इंजेक्ट कर सकता है, खिलाड़ी इनपुट सिमुलेट कर सकता है, गेम स्थिति को JSON के रूप में अवलोकन कर सकता है, और स्क्रीनशॉट ले सकता है — सब कोड परिवर्तनों के सही काम करने की पुष्टि के लिए।

### मल्टीप्लेयर परीक्षण कैसे काम करता है?

Open Godot MCP कई Godot इंस्टेंस (होस्ट + क्लाइंट) लॉन्च कर सकता है, पीयर सिमुलेट कर सकता है, नेटवर्क स्थितियाँ (विलंबता, पैकेट हानि) इंजेक्ट कर सकता है, और सत्यापित कर सकता है कि गेम स्थिति इंस्टेंस के बीच सिंक्रनाइज़्ड है।

---

## दस्तावेज़ीकरण

पूर्ण दस्तावेज़ अनुक्रमणिका: [Docs/README.md](Docs/README.md)। फ़ोल्डर द्वारा वियोजित।

| फ़ोल्डर | सामग्री |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | सुविधा अवलोकन, डिज़ाइन दर्शन |
| [Docs/01-Architecture/](Docs/01-Architecture/) | आर्किटेक्चर, प्रोटोकॉल, कनेक्शन स्थिरता, मल्टी-इंस्टेंस, रनटाइम |
| [Docs/02-Tools/](Docs/02-Tools/) | संपूर्ण उपकरण सूची (प्रति-डोमेन फ़ाइलें) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | नियतात्मक प्लेटेस्टिंग (गाइड + उदाहरण) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | टोकन-बचत डिज़ाइन (गाइड + रणनीतियाँ) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | मल्टीप्लेयर परीक्षण (गाइड + उदाहरण) |
| [Docs/06-Installation/](Docs/06-Installation/) | स्थापना (गाइड + समस्या-निवारण) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | विकास रोडमैप |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot संगतता और सिंटैक्स जाँच |
| [Docs/09-Research/](Docs/09-Research/) | मौजूदा MCP शोध, C# MCP शोध |

---

## आभार

Open Godot MCP दिग्गजों के कंधों पर खड़ा है, इनमें से सर्वश्रेष्ठ लेते हुए:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k स्टार) — मौलिक आर्किटेक्चर
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — नियतात्मक प्लेटेस्टिंग, सस्ती अवलोकन, पढ़ने/लिखने पृथक्करण
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — डिबगर चैनल रनटाइम, Undo/Redo, Windows पोर्ट आरक्षण, 20+ क्लाइंट विन्यास, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — द्वैत-चैनल आर्किटेक्चर, Variant सीरियलाइज़ेशन, डिलीट सुरक्षा
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP एकीकरण, मल्टी-इंस्टेंस, पोर्ट पृथक्करण
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — ज़ीरो-फुटप्रिंट, Godot के लिए Playwright संकल्पना
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149 उपकरण व्यापकता संदर्भ

---

## लाइसेंस

[MIT](LICENSE) — 100% ओपन सोर्स, सभी सुविधाएँ मुफ़्त, कोई फ्रीमियम नहीं, कोई पेवॉल नहीं।
