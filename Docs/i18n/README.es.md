<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Desarrollo, pruebas y depuración de juegos Godot con IA
@description: Servidor MCP de código abierto para desarrollo autónomo de juegos Godot con IA. Pruebas deterministas, pruebas multijugador, depuración DAP, integración LSP, eficiencia de tokens. 100% MIT.
@keywords: godot mcp, model context protocol, desarrollo de juegos con ia, godot ia, pruebas de juegos, playtesting, pruebas deterministas, pruebas multijugador, depuración de juegos, depurador dap, integración lsp, gdscript, godot 4, mcp de código abierto, asistente de codificación con ia, claude mcp, ia para motor de juegos, pruebas automatizadas de juegos, plugin de godot, eficiencia de tokens
@author: MasterYee Labs
@language: es
@og:type: software
@og:title: Open Godot MCP
@og:description: Servidor MCP de código abierto para desarrollo de juegos Godot con IA — pruebas deterministas, pruebas multijugador, depuración DAP, LSP, eficiencia de tokens.
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
  "description": "Servidor de Model Context Protocol de código abierto para el desarrollo, pruebas y depuración autónoma de juegos Godot con IA. Incluye pruebas deterministas, pruebas multijugador, depuración DAP, integración LSP y diseño eficiente en tokens.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Pruebas deterministas (freeze/step/step_until)",
    "Pruebas de juegos multijugador (multi-instancia, simulación de pares)",
    "Depuración DAP (breakpoints, stack_trace, variables, evaluate)",
    "Integración LSP (diagnóstico, autocompletado, ir a definición)",
    "Diseño eficiente en tokens (resumen JSON, diff, compresión de capturas)",
    "Más de 30 herramientas MCP, más de 130 acciones",
    "Estabilidad de conexión (latido, reconexión inteligente, evitación automática de puertos)"
  ],
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "5",
    "reviewCount": "1"
  }
}
</script>
-->


**Languages:** [繁體中文](../../README.md) | [English](README.en.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | Español（本檔） | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

# Open Godot MCP

> Servidor de Model Context Protocol (MCP) de código abierto, gratuito y con todas las funciones, que permite a la IA desarrollar, probar y depurar juegos de Godot de forma autónoma — incluyendo control real del juego, pruebas deterministas, pruebas multijugador, depuración DAP, integración LSP y diseño eficiente en tokens. 100% con licencia MIT, sin freemium, sin muro de pago.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Idiomas:** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## ¿Qué es Open Godot MCP?

**Open Godot MCP** es un servidor de [Model Context Protocol](https://modelcontextprotocol.io) de código abierto que conecta asistentes de codificación con IA (Claude, GPT, Cursor, Windsurf, etc.) al editor de [Godot Engine](https://godotengine.org). Permite que la IA **escriba código, ejecute el juego, pruebe el gameplay, depure en puntos de interrupción, inspeccione variables y verifique correcciones** — todo de forma autónoma, sin intervención humana.

A diferencia de los servidores Godot MCP existentes que solo editan escenas, Open Godot MCP permite que la IA **juegue el juego realmente** mediante pruebas deterministas (congelar reloj → avanzar tiempo → observar estado → verificar resultado). Es el **único** Godot MCP que soporta **pruebas de juegos multijugador**, **integración del depurador DAP** e **inteligencia de código LSP**.

| Atributo | Valor |
|-----------|-------|
| **Tipo de proyecto** | Servidor MCP (Model Context Protocol) para Godot Engine |
| **Motor objetivo** | Godot 4.5+ (soporte GDScript + C#) |
| **Runtime** | Python 3.11+ (servidor) + GDScript (addon) |
| **Licencia** | MIT (100% código abierto, sin freemium) |
| **Herramientas** | ~30 herramientas MCP, ~130 acciones |
| **Funciones clave** | Pruebas deterministas, pruebas multijugador, depuración DAP, LSP, eficiencia de tokens |
| **Clientes de IA** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, cualquier cliente compatible con MCP |
| **Plataformas** | Windows, macOS, Linux |
| **Capacidades únicas** | Pruebas multijugador (ningún otro Godot MCP tiene esto), integración DAP + LSP |

---

## Por qué existe

Cada Godot MCP en el mercado tiene deficiencias:

| Problema | MCPs existentes | Open Godot MCP |
|---------|--------------|-----------------|
| La IA no puede ver el juego ejecutándose realmente | Solo edición, no puede ejecutar el juego para corregir errores | **Pruebas deterministas** — congela el reloj, avanza tiempo preciso, step_until con condición |
| Conexión inestable | Puerto fijo, sin latido, conflictos con WSL2 | Puerto configurable + latido + reconexión inteligente + evitación automática de puertos |
| No puede probar multijugador | Todos los MCPs carecen de pruebas multijugador | **Único** — multi-instancia, simulación de pares, verificación de sincronización, inyección de condiciones de red |
| Desperdicio de tokens | Retornos completos, PNG sin comprimir, sin diff | Observación económica, compresión de capturas, diff, resúmenes, consultas incrementales |
| Castración freemium | Versión gratuita limitada, paga por funciones | **100% MIT de código abierto**, todas las funciones gratuitas |

---

## ¿Para quién es?

- **Desarrolladores de juegos que usan Godot 4** que quieren que la IA les ayude a escribir, probar y depurar sus juegos
- **Coders asistidos por IA** (usuarios de Claude, Cursor, Windsurf, VS Code MCP) que trabajan en proyectos de Godot
- **Estudios de juegos indie** que necesitan pruebas automatizadas sin escribir frameworks de testing
- **Desarrolladores de juegos multijugador** que necesitan probar sincronización de red, latencia y comportamiento de pares
- **Defensores del código abierto** que quieren un servidor MCP totalmente gratuito sin muro de pago

---

## Casos de uso

| Caso de uso | Cómo ayuda Open Godot MCP |
|----------|--------------------------|
| **La IA corrige un bug de movimiento** | La IA establece un punto de interrupción → ejecuta el juego → inspecciona variables → identifica la causa raíz → corrige el código → vuelve a probar |
| **Pruebas automatizadas de jefes** | Congelar reloj → generar jefe → avanzar tiempo → simular entrada de esquiva → verificar que el jugador sobrevive |
| **Verificación de sincronización multijugador** | Lanzar instancias host + cliente → inyectar latencia → comparar estado de sincronización → detectar bugs de desincronización |
| **Perfilado de rendimiento** | Tomar instantánea del profiler → identificar pico → optimizar → volver a medir |
| **Pruebas de regresión** | Ejecutar suite de pruebas tras cambio de código → afirmar que el estado del juego coincide con el esperado |
| **Iteración de diseño de niveles** | La IA crea nodos → organiza la escena → ejecuta el juego → captura el resultado → ajusta |

---

## Capacidades principales

### 1. Pruebas deterministas (resuelve "la IA no puede ver el juego ejecutándose")

La IA no solo escribe código — puede **jugar el juego por sí misma para verificar las correcciones**:

```
godot_game play frozen=true                    # Lanzar juego (reloj congelado)
godot_exec eval code="GameState.wave = 3"      # Configurar escenario de prueba
godot_game_time step_until "boss.size() >= 1"  # Esperar a que aparezca el jefe
godot_runtime_state digest                     # Observar estado (JSON, sin tokens de visión)
godot_game_time step ms=500 + dodge input      # Jugar el momento crítico
godot_screenshot game                          # Captura de pantalla solo cuando valga la pena
```

### 2. Pruebas multijugador (función única — ningún otro Godot MCP tiene esto)

Una capacidad que ningún Godot MCP existente tiene:

```
godot_network launch_instance role="host"      # Iniciar servidor
godot_network launch_instance role="client"    # Iniciar cliente
godot_network network_condition latency=200    # Inyectar 200ms de latencia
godot_network sync_state                       # Verificar sincronización multi-instancia
godot_network simulate_peer count=50           # Prueba de estrés con 50 pares
```

### 3. Eficiencia de tokens

Cada herramienta tiene un diseño de ahorro de tokens:

- **Observación económica**: el resumen de estado en JSON reemplaza las capturas de pantalla (ahorra 90% de tokens)
- **Retornos con diff**: solo se devuelven las partes modificadas
- **Compresión de capturas**: JPEG/WebP + guardar en disco (no en el contexto)
- **Separación lectura/escritura**: lectura auto-permitida, escritura restringida
- **Operaciones por lotes**: completa múltiples operaciones en un solo viaje de ida y vuelta

### 4. Estabilidad de conexión

Resuelve el problema de "no se puede conectar" en los MCPs existentes:

- Puerto configurable (env > EditorSettings > evitación automática)
- Detección de reserva de puertos en Windows (evita puertos reservados por Hyper-V/WSL2/Docker)
- Mecanismo de latido (detección proactiva de conexiones muertas)
- Reconexión inteligente (retroceso exponencial + reintentos máximos + notificación en UI)

### 5. Depuración completa

- **DAP (Debugger Adapter Protocol)**: puntos de interrupción, ejecución paso a paso, inspección de variables (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)**: diagnóstico estático, autocompletado, ir a definición
- **Profiler**: instantáneas de rendimiento, análisis de línea de tiempo, detección de picos

---

## Inicio rápido

### 1. Instalar el servidor MCP

```bash
uv tool install open-godot-mcp
# o
pip install open-godot-mcp
```

### 2. Configurar el cliente de IA

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Abrir el proyecto de Godot

El addon se inyecta automáticamente. Abre tu cliente de IA y comienza a usarlo.

Guía de instalación completa: [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Lista de herramientas

~30 herramientas, ~130 acciones. Diseño con separación de lectura/escritura.

| Dominio | Herramienta | Descripción |
|--------|------|-------------|
| Editor | `godot_editor_read/edit` | Estado, escena, selección |
| Escena | `godot_scene` | Crear, leer, guardar |
| Nodo | `godot_node_read/edit` | CRUD, propiedades, grupos, señales |
| Script | `godot_script` | Edición con diff, validación |
| Proyecto | `godot_project` | Configuración, autoloads |
| Input Map | `godot_input_map` | Gestión de InputMap |
| Recurso | `godot_resource` | Inspección con conocimiento de tipos |
| Animación | `godot_animation` | Crear, pistas, presets |
| TileMapLayer | `godot_tilemap` | Lectura/escritura de celdas |
| **Control de juego** | `godot_game` | play/stop/freeze |
| **Reloj** | `godot_game_time` | freeze/step/step_until |
| **Entrada** | `godot_input` | Teclado/ratón/gamepad/texto |
| **Estado** | `godot_runtime_state` | digest/watch/signals |
| **Inyección** | `godot_exec` | eval/call/assert |
| Captura de pantalla | `godot_screenshot` | Compresión, guardar en archivo |
| Depurador | `godot_debugger` | Puntos de interrupción DAP, stack_trace, variables, evaluate |
| Código | `godot_lsp` | Diagnóstico, completado |
| Profiler | `godot_profiler` | Instantáneas, línea de tiempo |
| Prueba | `godot_test` | Framework, ejecución |
| **Red** | `godot_network` | Multi-instancia, sincronización, condiciones de red |
| Instancia | `godot_instance` | Gestión multi-Godot |
| Sistema de archivos | `godot_filesystem` | Leer/escribir, buscar |
| Docs | `godot_docs` | Coincidencia de versión |
| Log | `godot_log` | Consulta incremental |
| Lote | `godot_batch` | Múltiples operaciones a la vez |
| Asset | `godot_asset` | Generación, gestión |
| Exportación | `godot_export` | Presets, exportación |
| Salud | `godot_health` | Verificación de conexión |

API completa: [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Comparación con servidores Godot MCP existentes

| Función | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Operaciones de editor | ✅ | ✅ | ✅ | ✅ | ✅ 149 herramientas | ✅ |
| Control real del juego | ⚠️ | ⚠️ | ❌ | ✅ determinista | ⚠️ | ✅ **determinista+tiempo real** |
| Pruebas multijugador | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **único** |
| Depuración DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Integración LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Eficiencia de tokens | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **integral** |
| Estabilidad de conexión | ⚠️ | ❌ | — | ✅ | — | ✅ **el más estable** |
| Licencia | abierto | abierto | MIT | MIT | MIT | **MIT** |

---

## Preguntas frecuentes

### ¿Qué es el Model Context Protocol (MCP)?

El [Model Context Protocol](https://modelcontextprotocol.io) es un estándar abierto que permite a los asistentes de IA conectarse a herramientas y fuentes de datos externas. Open Godot MCP es un servidor MCP que conecta la IA al editor de Godot Engine.

### ¿Qué versiones de Godot son compatibles?

Godot 4.5 y posteriores. El addon usa las APIs de Godot 4.x incluyendo `EditorDebuggerPlugin`, `EditorInspector` y el canal de mensajes del depurador.

### ¿Qué clientes de IA son compatibles?

Cualquier cliente compatible con MCP: Claude Desktop, Cursor, Windsurf, VS Code (con extensión MCP), Continue, Zed y cualquier cliente que soporte el estándar Model Context Protocol.

### ¿Soporta C# (la versión .NET de Godot)?

Sí. La verificación de sintaxis de C# y la verificación de compilación son compatibles. Consulta [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### ¿En qué se diferencia de otros servidores Godot MCP?

Open Godot MCP es el **único** Godot MCP que soporta pruebas de juegos multijugador, integración del depurador DAP (puntos de interrupción, stack traces, inspección de variables) e inteligencia de código LSP. También tiene el diseño de eficiencia de tokens más integral.

### ¿Es realmente gratuito?

Sí. 100% con licencia MIT, sin modelo freemium, sin muro de pago, sin funciones bloqueadas. Todas las funciones son gratuitas para todos.

### ¿La IA puede jugar el juego realmente?

Sí. Mediante pruebas deterministas, la IA puede congelar el reloj del juego, avanzar el tiempo en incrementos precisos, inyectar escenarios de prueba, simular la entrada del jugador, observar el estado del juego como JSON y tomar capturas de pantalla — todo para verificar que los cambios de código funcionan correctamente.

### ¿Cómo funcionan las pruebas multijugador?

Open Godot MCP puede lanzar múltiples instancias de Godot (host + clientes), simular pares, inyectar condiciones de red (latencia, pérdida de paquetes) y verificar que el estado del juego esté sincronizado entre las instancias.

---

## Documentación

Índice completo de documentación: [Docs/README.md](Docs/README.md). Desacoplado por carpeta.

| Carpeta | Contenido |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Resumen de funciones, filosofía de diseño |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Arquitectura, protocolo, estabilidad de conexión, multi-instancia, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Lista completa de herramientas (archivos por dominio) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Pruebas deterministas (Guía + Ejemplos) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Diseño de ahorro de tokens (Guía + Estrategias) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Pruebas multijugador (Guía + Ejemplos) |
| [Docs/06-Installation/](Docs/06-Installation/) | Instalación (Guía + Solución de problemas) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Hoja de ruta de desarrollo |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Compatibilidad de C# con Godot y verificación de sintaxis |
| [Docs/09-Research/](Docs/09-Research/) | Investigación de MCPs existentes, investigación de MCP en C# |

---

## Agradecimientos

Open Godot MCP se apoya en los hombros de gigantes, tomando lo mejor de:

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k estrellas) — arquitectura fundamental
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — pruebas deterministas, observación económica, separación lectura/escritura
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — runtime del canal del depurador, Undo/Redo, reserva de puertos en Windows, más de 20 configuraciones de cliente, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — arquitectura de doble canal, serialización de Variant, protección contra eliminación
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — integración DAP + LSP, multi-instancia, aislamiento de puertos
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — sin huella, concepto de Playwright para Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — referencia de amplitud con 149 herramientas

---

## Licencia

[MIT](LICENSE) — 100% de código abierto, todas las funciones gratuitas, sin freemium, sin muro de pago.
