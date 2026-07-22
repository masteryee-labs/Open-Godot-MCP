<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — AI Odaklı Godot Oyun Geliştirme, Test ve Hata Ayıklama
@description: AI otonom Godot oyun geliştirme için açık kaynak MCP sunucusu. Deterministik oyun testi, çok oyunculu test, DAP hata ayıklama, LSP entegrasyonu, token verimli. %100 MIT.
@keywords: godot mcp, model context protocol, ai oyun geliştirme, godot ai, oyun testi, oyun testi, deterministik test, çok oyunculu test, oyun hata ayıklama, dap hata ayıklayıcı, lsp entegrasyonu, gdscript, godot 4, açık kaynak mcp, ai kodlama asistanı, claude mcp, oyun motoru ai, otomatik oyun testi, godot eklenti, token verimliliği
@author: MasterYee Labs
@language: tr
@og:type: software
@og:title: Open Godot MCP
@og:description: AI odaklı Godot oyun geliştirme için açık kaynak MCP sunucusu — deterministik oyun testi, çok oyunculu test, DAP hata ayıklama, LSP, token verimli.
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
  "description": "AI otonom Godot oyun geliştirme, test ve hata ayıklama için açık kaynak Model Context Protocol sunucusu. Deterministik oyun testi, çok oyunculu test, DAP hata ayıklama, LSP entegrasyonu ve token verimli tasarım özellikleri içerir.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Deterministik oyun testi (freeze/step/step_until)",
    "Çok oyunculu oyun testi (çoklu örnek, peer simülasyonu)",
    "DAP hata ayıklama (kesme noktaları, stack_trace, değişkenler, evaluate)",
    "LSP entegrasyonu (tanılama, otomatik tamamlama, tanıma-git)",
    "Token verimli tasarım (JSON özet, diff, ekran görüntüsü sıkıştırma)",
    "30+ MCP araç, 130+ eylem",
    "Bağlantı kararlılığı (kalp atışı, akıllı yeniden bağlanma, port otomatik kaçınma)"
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "5",
    "reviewCount": "1"
  }
}
</script>
-->


**Languages:** [繁體中文](../../README.md) | [English](README.en.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | Türkçe（本檔） | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

# Open Godot MCP

> Açık kaynaklı, ücretsiz, tam özellikli Model Context Protocol (MCP) sunucusu — yapay zekanın Godot oyunlarını otonom olarak geliştirmesini, test etmesini ve hata ayıklamasını sağlar; gerçek oyun kontrolü, deterministik oyun testi, çok oyunculu test, DAP hata ayıklama, LSP entegrasyonu ve token verimli tasarım dahil. %100 MIT lisanslı, freemium yok, ödeme duvarı yok.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Diller:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Open Godot MCP Nedir?

**Open Godot MCP**, AI kodlama asistanlarını (Claude, GPT, Cursor, Windsurf vb.) [Godot Engine](https://godotengine.org) editörüne bağlayan açık kaynaklı bir [Model Context Protocol](https://modelcontextprotocol.io) sunucusudur. AI'nin **kod yazmasını, oyunu çalıştırmasını, oynanışı test etmesini, kesme noktalarında hata ayıklamasını, değişkenleri incelemesini ve düzeltmeleri doğrulamasını** sağlar — hepsi otonom olarak, insan müdahalesi olmadan.

Sadece sahneleri düzenleyen mevcut Godot MCP sunucularından farklı olarak, Open Godot MCP AI'nin deterministik oyun testi ile **oyunu gerçekten oynamasını** sağlar (saati dondur → zaman adımla → durumu gözlemle → sonucu doğrula). **Çok oyunculu oyun testini**, **DAP hata ayıklayıcı entegrasyonunu** ve **LSP kod zekasını** destekleyen **tek** Godot MCP'dir.

| Özellik | Değer |
|-----------|-------|
| **Proje türü** | Godot Engine için MCP sunucusu (Model Context Protocol) |
| **Hedef motor** | Godot 4.5+ (GDScript + C# desteği) |
| **Çalışma zamanı** | Python 3.11+ (sunucu) + GDScript (eklenti) |
| **Lisans** | MIT (%100 açık kaynak, freemium yok) |
| **Araçlar** | ~30 MCP araç, ~130 eylem |
| **Temel özellikler** | Deterministik oyun testi, çok oyunculu test, DAP hata ayıklama, LSP, token verimliliği |
| **AI istemcileri** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, MCP uyumlu herhangi bir istemci |
| **Platformlar** | Windows, macOS, Linux |
| **Benzersiz yetenekler** | Çok oyunculu test (başka Godot MCP'de yok), DAP + LSP entegrasyonu |

---

## Bu Neden Var?

Piyasadaki her Godot MCP'in eksiklikleri var:

| Sorun | Mevcut MCP'ler | Open Godot MCP |
|---------|--------------|-----------------|
| AI oyunun gerçekten çalıştığını göremez | Sadece düzenleme, hatayı düzeltmek için oyunu oynayamaz | **Deterministik oyun testi** — saati dondur, kesin zaman adımı, step_until koşulu |
| Kararsız bağlantı | Sabit kodlanmış port, kalp atışı yok, WSL2 çakışmaları | Yapılandırılabilir port + kalp atışı + akıllı yeniden bağlanma + port otomatik kaçınma |
| Çok oyunculu test yapılamaz | Tüm MCP'lerde çok oyunculu test yok | **Benzersiz** — çoklu örnek, peer simülasyonu, senkron doğrulama, ağ koşulu enjeksiyonu |
| Token israfı | Tam dönüşler, sıkıştırılmamış PNG, diff yok | Ucuz gözlem, ekran görüntüsü sıkıştırma, diff, özetler, artımlı sorgular |
| Freemium kısıtlaması | Ücretsiz sürüm sınırlı, özellikler için öde | **%100 MIT açık kaynak**, tüm özellikler ücretsiz |

---

## Kimler için?

- Oyunlarını yazmasında, test etmesinde ve hata ayıklamasında AI'nin yardımcı olmasını isteyen **Godot 4 kullanan oyun geliştiricileri**
- Godot projeleri üzerinde çalışan **AI destekli kodlayıcılar** (Claude, Cursor, Windsurf, VS Code MCP kullanıcıları)
- Test çerçeveleri yazmadan otomatik oyun testi gerektiren **bağımsız oyun stüdyoları**
- Ağ senkronizasyonu, gecikme ve peer davranışını test etmesi gereken **çok oyunculu oyun geliştiricileri**
- Ödeme duvarı olmayan tamamen ücretsiz bir MCP sunucusu isteyen **açık kaynak savunucuları**

---

## Kullanım Senaryoları

| Senaryo | Open Godot MCP Nasıl Yardımcı Olur |
|----------|--------------------------|
| **AI bir hareket hatasını düzeltir** | AI kesme noktası koyar → oyunu çalıştırır → değişkenleri inceler → kök nedeni belirler → kodu düzeltir → yeniden test eder |
| **Otomatik boss savaşı testi** | Saati dondur → boss oluştur → zaman adımla → dodge girişi simüle et → oyuncunun hayatta kaldığını doğrula |
| **Çok oyunculu senkron doğrulama** | Host + istemci örnekleri başlat → gecikme enjekte et → senkron durumunu karşılaştır → desync hatalarını tespit et |
| **Performans profilleme** | Profil oluşturucu anlık görüntüsü al → spike'ı belirle → optimize et → yeniden ölç |
| **Regresyon testi** | Kod değişikliğinden sonra test paketini çalıştır → oyun durumunun beklenenle eşleştiğini doğrula |
| **Seviye tasarımı yinelemesi** | AI düğümler oluşturur → sahneyi düzenler → oyunu çalıştırır → sonucu ekran görüntüsü alır → ayarlar |

---

## Temel Yetenekler

### 1. Deterministik Oyun Testi ("AI oyunun çalıştığını göremez" sorununu çözer)

AI sadece kod yazmaz — **düzeltmeleri doğrulamak için oyunu kendisi oynayabilir**:

```
godot_game play frozen=true                    # Oyunu başlat (dondurulmuş saat)
godot_exec eval code="GameState.wave = 3"      # Test senaryosu kur
godot_game_time step_until "boss.size() >= 1"  # Boss'un ortaya çıkmasını bekle
godot_runtime_state digest                     # Durumu gözlemle (JSON, görme token'ı yok)
godot_game_time step ms=500 + dodge input      # Kritik anı oyna
godot_screenshot game                          # Sadece değerli olduğunda ekran görüntüsü al
```

### 2. Çok Oyunculu Test (benzersiz özellik — başka hiçbir Godot MCP'de yok)

Mevcut hiçbir Godot MCP'in sahip olmadığı bir yetenek:

```
godot_network launch_instance role="host"      # Sunucu başlat
godot_network launch_instance role="client"    # İstemci başlat
godot_network network_condition latency=200    # 200ms gecikme enjekte et
godot_network sync_state                       # Çoklu örnek senkronunu doğrula
godot_network simulate_peer count=50           # 50 peer ile stres testi
```

### 3. Token Verimliliği

Her araçta token tasarrufu tasarımı:

- **Ucuz gözlem**: JSON durum özeti ekran görüntüsünün yerini alır (%90 token tasarrufu)
- **Diff dönüşleri**: Sadece değişen kısımları döndür
- **Ekran görüntüsü sıkıştırma**: JPEG/WebP + diske kaydet (bağlamda değil)
- **Okuma/yazma ayrımı**: okuma otomatik izinli, yazma kontrollü
- **Toplu işlemler**: Birden fazla işlemi tek gidiş-dönüşte tamamla

### 4. Bağlantı Kararlılığı

Mevcut MCP'lerdeki "bağlanılamıyor" sorununu çözer:

- Yapılandırılabilir port (ortam değişkeni > EditorSettings > otomatik kaçınma)
- Windows Port Rezervasyonu algılama (Hyper-V/WSL2/Docker rezerve portlarından kaçın)
- Kalp atışı mekanizması (proaktif ölü bağlantı algılama)
- Akıllı yeniden bağlanma (üstel geri çekilme + maksimum deneme + UI bildirimi)

### 5. Tam Hata Ayıklama

- **DAP (Debugger Adapter Protocol)**: kesme noktaları, adımlama, değişken inceleme (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: statik tanılama, otomatik tamamlama, tanıma-git
- **Profil oluşturucu**: performans anlık görüntüleri, zaman çizelgesi analizi, spike algılama

---

## Hızlı Başlangıç

### 1. MCP Sunucusunu Kur

```bash
uv tool install open-godot-mcp
# veya
pip install open-godot-mcp
```

### 2. AI İstemcisini Yapılandır

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Godot Projesini Aç

Eklenti otomatik enjekte edilir. AI istemcinizi açın ve kullanmaya başlayın.

Tam kurulum kılavuzu: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Araç Listesi

~30 araç, ~130 eylem. Okuma/yazma ayrımı tasarımı.

| Alan | Araç | Açıklama |
|--------|------|-------------|
| Editör | `godot_editor_read/edit` | Durum, sahne, seçim |
| Sahne | `godot_scene` | Oluştur, oku, kaydet |
| Düğüm | `godot_node_read/edit` | CRUD, özellikler, gruplar, sinyaller |
| Betik | `godot_script` | Diff düzenleme, doğrulama |
| Proje | `godot_project` | Ayarlar, autoload'lar |
| Giriş Haritası | `godot_input_map` | InputMap yönetimi |
| Kaynak | `godot_resource` | Tür duyarlı inceleme |
| Animasyon | `godot_animation` | Oluştur, parçalar, ön ayarlar |
| TileMapLayer | `godot_tilemap` | Hücre oku/yaz |
| **Oyun Kontrolü** | `godot_game` | oynat/durdur/dondur |
| **Saat** | `godot_game_time` | dondur/adım/step_until |
| **Giriş** | `godot_input` | Klavye/fare/gamepad/metin |
| **Durum** | `godot_runtime_state` | özet/izle/sinyaller |
| **Enjeksiyon** | `godot_exec` | eval/çağır/assert |
| Ekran Görüntüsü | `godot_screenshot` | Sıkıştırma, dosyaya kaydet |
| Hata Ayıklayıcı | `godot_debugger` | DAP kesme noktaları, stack_trace, variables, evaluate |
| Kod | `godot_lsp` | Tanılama, tamamlama |
| Profil Oluşturucu | `godot_profiler` | Anlık görüntüler, zaman çizelgesi |
| Test | `godot_test` | Çerçeve, yürütme |
| **Ağ** | `godot_network` | Çoklu örnek, senkron, ağ koşulları |
| Örnek | `godot_instance` | Çoklu Godot yönetimi |
| Dosya Sistemi | `godot_filesystem` | Oku/yaz, ara |
| Dokümanlar | `godot_docs` | Sürümle eşleşen |
| Günlük | `godot_log` | Artımlı sorgu |
| Toplu | `godot_batch` | Tek seferde birden fazla işlem |
| Varlık | `godot_asset` | Üretim, yönetim |
| Dışa Aktarma | `godot_export` | Ön ayarlar, dışa aktarma |
| Sağlık | `godot_health` | Bağlantı kontrolü |

Tam API: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Mevcut Godot MCP Sunucularıyla Karşılaştırma

| Özellik | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Editör işlemleri | ✅ | ✅ | ✅ | ✅ | ✅ 149 araç | ✅ |
| Gerçek oyun kontrolü | ⚠️ | ⚠️ | ❌ | ✅ deterministik | ⚠️ | ✅ **deterministik+gerçek zamanlı** |
| Çok oyunculu test | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **benzersiz** |
| DAP hata ayıklama | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| LSP entegrasyonu | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Token verimliliği | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **kapsamlı** |
| Bağlantı kararlılığı | ⚠️ | ❌ | — | ✅ | — | ✅ **en kararlı** |
| Lisans | açık | açık | MIT | MIT | MIT | **MIT** |

---

## SSS

### Model Context Protocol (MCP) nedir?

[Model Context Protocol](https://modelcontextprotocol.io), AI asistanlarının harici araçlara ve veri kaynaklarına bağlanmasını sağlayan açık bir standarttır. Open Godot MCP, AI'yı Godot Engine editörüne bağlayan bir MCP sunucusudur.

### Hangi Godot sürümleri destekleniyor?

Godot 4.5 ve daha yenileri. Eklenti, `EditorDebuggerPlugin`, `EditorInspector` ve hata ayıklayıcı mesaj kanalı dahil Godot 4.x API'lerini kullanır.

### Hangi AI istemcileri uyumlu?

MCP uyumlu herhangi bir istemci: Claude Desktop, Cursor, Windsurf, VS Code (MCP uzantısıyla), Continue, Zed ve Model Context Protocol standardını destekleyen herhangi bir istemci.

### C# (Godot'un .NET sürümü) destekleniyor mu?

Evet. C# sözdizimi kontrolü ve derleme doğrulaması desteklenir. Bkz. [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Bu, diğer Godot MCP sunucularından nasıl farklı?

Open Godot MCP, çok oyunculu oyun testini, DAP hata ayıklayıcı entegrasyonunu (kesme noktaları, yığın izleri, değişken inceleme) ve LSP kod zekasını destekleyen **tek** Godot MCP'dir. Ayrıca en kapsamlı token verimliliği tasarımına sahiptir.

### Gerçekten ücretsiz mi?

Evet. %100 MIT lisanslı, freemium modeli yok, ödeme duvarı yok, özellik kısıtlaması yok. Tüm özellikler herkes için ücretsizdir.

### AI oyunu gerçekten oynayabilir mi?

Evet. Deterministik oyun testi aracılığıyla AI, oyun saatini dondurabilir, zamanı kesin artışlarla ileri adımlayabilir, test senaryoları enjekte edebilir, oyuncu girişini simüle edebilir, oyun durumunu JSON olarak gözlemleyebilir ve ekran görüntüleri alabilir — hepsi kod değişikliklerinin doğru çalıştığını doğrulamak için.

### Çok oyunculu test nasıl çalışır?

Open Godot MCP, birden fazla Godot örneği (host + istemciler) başlatabilir, peer'ları simüle edebilir, ağ koşulları (gecikme, paket kaybı) enjekte edebilir ve oyun durumunun örnekler arasında senkronize olduğunu doğrulayabilir.

---

## Dokümantasyon

Tam dokümantasyon dizini: [Docs/README.md](Docs/README.md). Klasöre göre ayrılmış.

| Klasör | İçerik |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Özellik genel bakışı, tasarım felsefesi |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Mimari, protokol, bağlantı kararlılığı, çoklu örnek, çalışma zamanı |
| [Docs/02-Tools/](Docs/02-Tools/) | Tam araç listesi (alan bazlı dosyalar) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Deterministik oyun testi (Kılavuz + Örnekler) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Token tasarrufu tasarımı (Kılavuz + Stratejiler) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Çok oyunculu test (Kılavuz + Örnekler) |
| [Docs/06-Installation/](Docs/06-Installation/) | Kurulum (Kılavuz + Sorun Giderme) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Geliştirme yol haritası |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | C# Godot uyumluluğu ve sözdizimi kontrolü |
| [Docs/09-Research/](Docs/09-Research/) | Mevcut MCP araştırması, C# MCP araştırması |

---

## Teşekkürler

Open Godot MCP devlerin omuzlarında durur, en iyilerini alır:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k yıldız) — temel mimari
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — deterministik oyun testi, ucuz gözlem, okuma/yazma ayrımı
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — hata ayıklayıcı kanal çalışma zamanı, Geri Al/Yinele, Windows port rezervasyonu, 20+ istemci yapılandırması, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — çift kanallı mimari, Variant serileştirme, silme koruması
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — DAP + LSP entegrasyonu, çoklu örnek, port izolasyonu
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — sıfır ayak izi, Godot için Playwright konsepti
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — 149 araç genişlik referansı

---

## Lisans

[MIT](LICENSE) — %100 açık kaynak, tüm özellikler ücretsiz, freemium yok, ödeme duvarı yok.
