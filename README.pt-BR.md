<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Desenvolvimento, Testes e Depuração de Jogos Godot com IA
@description: Servidor MCP de código aberto para desenvolvimento autônomo de jogos Godot com IA. Playtesting determinístico, testes multiplayer, depuração DAP, integração LSP, eficiência de tokens. 100% MIT.
@keywords: godot mcp, model context protocol, desenvolvimento de jogos com ia, godot ia, testes de jogos, playtesting, testes determinísticos, testes multiplayer, depuração de jogos, dap debugger, integração lsp, gdscript, godot 4, mcp código aberto, assistente de codificação com ia, claude mcp, ia motor de jogos, testes automatizados de jogos, plugin godot, eficiência de tokens
@author: MasterYee Labs
@language: pt-BR
@og:type: software
@og:title: Open Godot MCP
@og:description: Servidor MCP de código aberto para desenvolvimento de jogos Godot com IA — playtesting determinístico, testes multiplayer, depuração DAP, LSP, eficiência de tokens.
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
  "description": "Servidor Model Context Protocol de código aberto para desenvolvimento, testes e depuração autônomos de jogos Godot com IA. Recursos incluem playtesting determinístico, testes multiplayer, depuração DAP, integração LSP e design eficiente em tokens.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Playtesting determinístico (freeze/step/step_until)",
    "Testes de jogos multiplayer (multi-instância, simulação de peers)",
    "Depuração DAP (breakpoints, stack_trace, variables, evaluate)",
    "Integração LSP (diagnósticos, autocompletar, ir para definição)",
    "Design eficiente em tokens (digest JSON, diff, compressão de screenshot)",
    "30+ ferramentas MCP, 130+ ações",
    "Estabilidade de conexão (heartbeat, reconexão inteligente, auto-evitar portas)"
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

> Servidor Model Context Protocol (MCP) de código aberto, gratuito e completo que permite à IA desenvolver, testar e depurar jogos Godot de forma autônoma — incluindo controle real do jogo, playtesting determinístico, testes multiplayer, depuração DAP, integração LSP e design eficiente em tokens. 100% licenciado MIT, sem freemium, sem paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Languages:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## O que é o Open Godot MCP?

O **Open Godot MCP** é um servidor [Model Context Protocol](https://modelcontextprotocol.io) de código aberto que conecta assistentes de codificação com IA (Claude, GPT, Cursor, Windsurf, etc.) ao editor da [Godot Engine](https://godotengine.org). Ele permite que a IA **escreva código, execute o jogo, teste a jogabilidade, depure em breakpoints, inspecione variáveis e verifique correções** — tudo de forma autônoma, sem intervenção humana.

Diferente dos MCPs Godot existentes que apenas editam cenas, o Open Godot MCP permite que a IA **jogue o jogo de verdade** através de playtesting determinístico (congela relógio → avança tempo → observa estado → verifica resultado). É o **único** MCP Godot que suporta **testes de jogos multiplayer**, **integração com depurador DAP** e **inteligência de código LSP**.

| Atributo | Valor |
|-----------|-------|
| **Tipo de projeto** | Servidor MCP (Model Context Protocol) para Godot Engine |
| **Engine alvo** | Godot 4.5+ (suporte GDScript + C#) |
| **Runtime** | Python 3.11+ (servidor) + GDScript (addon) |
| **Licença** | MIT (100% código aberto, sem freemium) |
| **Ferramentas** | ~30 ferramentas MCP, ~130 ações |
| **Recursos principais** | Playtesting determinístico, testes multiplayer, depuração DAP, LSP, eficiência de tokens |
| **Clientes de IA** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, qualquer cliente compatível com MCP |
| **Plataformas** | Windows, macOS, Linux |
| **Capacidades únicas** | Testes multiplayer (nenhum outro MCP Godot tem isso), integração DAP + LSP |

---

## Por que isto existe

Todo Godot MCP no mercado tem deficiências:

| Problema | MCPs existentes | Open Godot MCP |
|---------|--------------|-----------------|
| IA não consegue ver o jogo rodando de verdade | Apenas edição, não consegue jogar o jogo para corrigir bugs | **Playtesting determinístico** — congela o relógio, avança tempo preciso, step_until até condição |
| Conexão instável | Porta fixa no código, sem heartbeat, conflitos com WSL2 | Porta configurável + heartbeat + reconexão inteligente + auto-evitar portas |
| Não consegue testar multiplayer | Todos os MCPs não têm testes multiplayer | **Único** — multi-instância, simulação de peers, verificação de sincronia, injeção de condições de rede |
| Desperdício de tokens | Retornos completos, PNG sem compressão, sem diff | Observação barata, compressão de screenshot, diff, resumos, consultas incrementais |
| Limitação freemium | Versão gratuita limitada, pague por recursos | **100% MIT código aberto**, todos os recursos gratuitos |

---

## Para quem é?

- **Desenvolvedores de jogos usando Godot 4** que querem que a IA ajude a escrever, testar e depurar seus jogos
- **Codadores com assistência de IA** (Claude, Cursor, Windsurf, usuários de MCP no VS Code) trabalhando em projetos Godot
- **Estúdios de jogos indie** que precisam de playtesting automatizado sem escrever frameworks de teste
- **Desenvolvedores de jogos multiplayer** que precisam testar sincronia de rede, latência e comportamento de peers
- **Defensores de código aberto** que querem um servidor MCP totalmente gratuito, sem paywall

---

## Casos de uso

| Caso de uso | Como o Open Godot MCP ajuda |
|----------|--------------------------|
| **IA corrige um bug de movimento** | IA define breakpoint → executa jogo → inspeciona variáveis → identifica causa raiz → corrige código → testa novamente |
| **Teste automatizado de luta contra boss** | Congela relógio → spawna boss → avança tempo → simula input de esquiva → verifica se jogador sobrevive |
| **Verificação de sincronia multiplayer** | Inicia instâncias host + cliente → injeta latência → compara estado de sincronia → detecta bugs de dessincronia |
| **Profiling de desempenho** | Tira snapshot do profiler → identifica pico → otimiza → mede novamente |
| **Testes de regressão** | Executa suíte de testes após mudança de código → verifica se estado do jogo corresponde ao esperado |
| **Iteração de design de fases** | IA cria nós → organiza cena → executa jogo → tira screenshot do resultado → ajusta |

---

## Capacidades principais

### 1. Playtesting determinístico (resolve "IA não consegue ver o jogo rodando")

A IA não apenas escreve código — ela pode **jogar o jogo para verificar as correções**:

```
godot_game play frozen=true                    # Inicia o jogo (relógio congelado)
godot_exec eval code="GameState.wave = 3"      # Configura cenário de teste
godot_game_time step_until "boss.size() >= 1"  # Espera o boss aparecer
godot_runtime_state digest                     # Observa estado (JSON, sem tokens de visão)
godot_game_time step ms=500 + dodge input      # Joga o momento crítico
godot_screenshot game                          # Screenshot apenas quando valer a pena
```

### 2. Testes multiplayer (recurso único — nenhum outro MCP Godot tem isso)

Uma capacidade que nenhum Godot MCP existente possui:

```
godot_network launch_instance role="host"      # Inicia servidor
godot_network launch_instance role="client"    # Inicia cliente
godot_network network_condition latency=200    # Injeta 200ms de latência
godot_network sync_state                       # Verifica sincronia entre instâncias
godot_network simulate_peer count=50           # Teste de estresse com 50 peers
```

### 3. Eficiência de tokens

Cada ferramenta tem design de economia de tokens:

- **Observação barata**: digest de estado em JSON substitui screenshots (economiza 90% dos tokens)
- **Retornos com diff**: Retorna apenas as partes alteradas
- **Compressão de screenshot**: JPEG/WebP + salva no disco (não no contexto)
- **Separação leitura/escrita**: leitura auto-permitida, escrita controlada
- **Operações em lote**: Completa múltiplas operações em uma viagem de ida e volta

### 4. Estabilidade de conexão

Resolve o problema "não consigo conectar" dos MCPs existentes:

- Porta configurável (env > EditorSettings > auto-evitar)
- Detecção de reserva de portas no Windows (evita portas reservadas por Hyper-V/WSL2/Docker)
- Mecanismo de heartbeat (detecção proativa de conexões mortas)
- Reconexão inteligente (backoff exponencial + máximo de tentativas + notificação na UI)

### 5. Depuração completa

- **DAP (Debugger Adapter Protocol)**: breakpoints, stepping, inspeção de variáveis (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: diagnósticos estáticos, autocompletar, ir para definição
- **Profiler**: snapshots de desempenho, análise de timeline, detecção de picos

---

## Início rápido

### 1. Instalar o servidor MCP

```bash
uv tool install open-godot-mcp
# ou
pip install open-godot-mcp
```

### 2. Configurar o cliente de IA

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Abrir o projeto Godot

O addon é auto-injetado. Abra seu cliente de IA e comece a usar.

Guia de instalação completo: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Lista de ferramentas

~30 ferramentas, ~130 ações. Design com separação leitura/escrita.

| Domínio | Ferramenta | Descrição |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | Estado, cena, seleção |
| Scene | `godot_scene` | Criar, ler, salvar |
| Node | `godot_node_read/edit` | CRUD, propriedades, grupos, sinais |
| Script | `godot_script` | Edição com diff, validação |
| Project | `godot_project` | Configurações, autoloads |
| Input Map | `godot_input_map` | Gerenciamento do InputMap |
| Resource | `godot_resource` | Inspeção com reconhecimento de tipo |
| Animation | `godot_animation` | Criar, tracks, presets |
| TileMapLayer | `godot_tilemap` | Leitura/escrita de células |
| **Controle de jogo** | `godot_game` | play/stop/freeze |
| **Relógio** | `godot_game_time` | freeze/step/step_until |
| **Input** | `godot_input` | Teclado/mouse/gamepad/texto |
| **Estado** | `godot_runtime_state` | digest/watch/signals |
| **Injeção** | `godot_exec` | eval/call/assert |
| Screenshot | `godot_screenshot` | Compressão, salvar em arquivo |
| Debugger | `godot_debugger` | DAP breakpoints, stack_trace, variables, evaluate |
| Código | `godot_lsp` | Diagnósticos, autocompletar |
| Profiler | `godot_profiler` | Snapshots, timeline |
| Teste | `godot_test` | Framework, execução |
| **Rede** | `godot_network` | Multi-instância, sincronia, condições de rede |
| Instância | `godot_instance` | Gerenciamento de múltiplos Godot |
| Filesystem | `godot_filesystem` | Leitura/escrita, busca |
| Docs | `godot_docs` | Correspondente à versão |
| Log | `godot_log` | Consulta incremental |
| Lote | `godot_batch` | Múltiplas operações de uma vez |
| Asset | `godot_asset` | Geração, gerenciamento |
| Export | `godot_export` | Presets, exportação |
| Health | `godot_health` | Verificação de conexão |

API completa: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Comparação com MCPs Godot existentes

| Recurso | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Operações de editor | ✅ | ✅ | ✅ | ✅ | ✅ 149 ferramentas | ✅ |
| Controle real do jogo | ⚠️ | ⚠️ | ❌ | ✅ determinístico | ⚠️ | ✅ **determinístico+tempo real** |
| Testes multiplayer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **único** |
| Depuração DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Integração LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Eficiência de tokens | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **abrangente** |
| Estabilidade de conexão | ⚠️ | ❌ | — | ✅ | — | ✅ **mais estável** |
| Licença | aberto | aberto | MIT | MIT | MIT | **MIT** |

---

## FAQ

### O que é o Model Context Protocol (MCP)?

O [Model Context Protocol](https://modelcontextprotocol.io) é um padrão aberto que permite que assistentes de IA se conectem a ferramentas e fontes de dados externas. O Open Godot MCP é um servidor MCP que conecta a IA ao editor da Godot Engine.

### Quais versões do Godot são suportadas?

Godot 4.5 e mais recentes. O addon usa APIs do Godot 4.x incluindo `EditorDebuggerPlugin`, `EditorInspector` e o canal de mensagens do depurador.

### Quais clientes de IA são compatíveis?

Qualquer cliente compatível com MCP: Claude Desktop, Cursor, Windsurf, VS Code (com extensão MCP), Continue, Zed e qualquer cliente que suporte o padrão Model Context Protocol.

### Suporta C# (versão .NET do Godot)?

Sim. Verificação de sintaxe C# e verificação de compilação são suportadas. Veja [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### Como isso difere de outros servidores MCP Godot?

O Open Godot MCP é o **único** MCP Godot que suporta testes de jogos multiplayer, integração com depurador DAP (breakpoints, stack traces, inspeção de variáveis) e inteligência de código LSP. Também possui o design de eficiência de tokens mais abrangente.

### É realmente gratuito?

Sim. 100% licenciado MIT, sem modelo freemium, sem paywall, sem restrição de recursos. Todos os recursos são gratuitos para todos.

### A IA consegue jogar o jogo de verdade?

Sim. Através de playtesting determinístico, a IA pode congelar o relógio do jogo, avançar o tempo em incrementos precisos, injetar cenários de teste, simular input do jogador, observar o estado do jogo como JSON e tirar screenshots — tudo para verificar se as mudanças de código funcionam corretamente.

### Como funcionam os testes multiplayer?

O Open Godot MCP pode iniciar múltiplas instâncias do Godot (host + clientes), simular peers, injetar condições de rede (latência, perda de pacotes) e verificar se o estado do jogo está sincronizado entre as instâncias.

---

## Documentação

Índice completo da documentação: [Docs/README.md](Docs/README.md). Organizado por pasta.

| Pasta | Conteúdo |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Visão geral de recursos, filosofia de design |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Arquitetura, protocolo, estabilidade de conexão, multi-instância, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Lista completa de ferramentas (arquivos por domínio) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Playtesting determinístico (Guia + Exemplos) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Design de economia de tokens (Guia + Estratégias) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Testes multiplayer (Guia + Exemplos) |
| [Docs/06-Installation/](Docs/06-Installation/) | Instalação (Guia + Solução de problemas) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Roteiro de desenvolvimento |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Compatibilidade C# Godot e verificação de sintaxe |
| [Docs/09-Research/](Docs/09-Research/) | Pesquisa de MCPs existentes, pesquisa de MCP em C# |

---

## Agradecimentos

O Open Godot MCP está sobre os ombros de gigantes, aproveitando o melhor de:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k stars) — arquitetura fundamental
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — playtesting determinístico, observação barata, separação leitura/escrita
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime via canal do depurador, Undo/Redo, reserva de portas no Windows, 20+ configurações de cliente, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — arquitetura de canal duplo, serialização Variant, proteção contra exclusão
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — integração DAP + LSP, multi-instância, isolamento de porta
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — footprint zero, conceito de Playwright para Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — referência de amplitude com 149 ferramentas

---

## Licença

[MIT](LICENSE) — 100% código aberto, todos os recursos gratuitos, sem freemium, sem paywall.
