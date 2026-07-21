<!--
SEO/AEO/GEO/LLMO Meta Block
=============================
@title: Open Godot MCP — Développement, test et débogage de jeux Godot pilotés par IA
@description: Serveur MCP open-source pour le développement de jeux Godot de manière autonome par l'IA. Playtesting déterministe, tests multijoueur, débogage DAP, intégration LSP, efficacité des tokens. 100% MIT.
@keywords: godot mcp, model context protocol, développement de jeux par ia, godot ia, test de jeux, playtesting, test déterministe, test multijoueur, débogage de jeux, débogueur dap, intégration lsp, gdscript, godot 4, mcp open source, assistant de codage ia, claude mcp, ia moteur de jeu, test de jeux automatisé, plugin godot, efficacité des tokens
@author: MasterYee Labs
@language: fr
@og:type: software
@og:title: Open Godot MCP
@og:description: Serveur MCP open-source pour le développement de jeux Godot piloté par l'IA — playtesting déterministe, tests multijoueur, débogage DAP, LSP, efficacité des tokens.
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
  "description": "Serveur Model Context Protocol open-source pour le développement, les tests et le débogage autonomes de jeux Godot par l'IA. Fonctionnalités : playtesting déterministe, tests multijoueur, débogage DAP, intégration LSP et conception économe en tokens.",
  "url": "https://github.com/masteryee-labs/Open-Godot-MCP",
  "programmingLanguage": ["GDScript", "Python"],
  "framework": "Godot Engine 4.5+",
  "offers": {
    "@type": "Offer",
    "price": "0",
    "priceCurrency": "USD"
  },
  "featureList": [
    "Playtesting déterministe (freeze/step/step_until)",
    "Tests de jeux multijoueur (multi-instance, simulation de pairs)",
    "Débogage DAP (points d'arrêt, stack_trace, variables, evaluate)",
    "Intégration LSP (diagnostics, autocomplétion, go-to-definition)",
    "Conception économe en tokens (résumé JSON, diff, compression de captures d'écran)",
    "Plus de 30 outils MCP, plus de 130 actions",
    "Stabilité de connexion (heartbeat, reconnexion intelligente, évitement automatique de port)"
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

> Serveur Model Context Protocol open-source, gratuit et complet qui permet à l'IA de développer, tester et déboguer de manière autonome des jeux Godot — y compris le contrôle de jeu en temps réel, le playtesting déterministe, les tests multijoueur, le débogage DAP, l'intégration LSP et une conception économe en tokens. 100% sous licence MIT, pas de freemium, pas de paywall.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)](https://godotengine.org)
[![Python 3.11+](https://img.shields.io/badge/Python-3.11+-green.svg)](https://python.org)
[![MCP](https://badge.mcpx.dev?type=server)](https://modelcontextprotocol.io)

**Langues :** [繁體中文](README.md) | English (this file) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md) | [Français](README.fr.md) | [Deutsch](README.de.md) | [Русский](README.ru.md) | [Português-BR](README.pt-BR.md) | [Polski](README.pl.md) | [Italiano](README.it.md) | [Türkçe](README.tr.md) | [ภาษาไทย](README.th.md) | [Tiếng Việt](README.vi.md) | [Bahasa Indonesia](README.id.md) | [Українська](README.uk.md) | [Nederlands](README.nl.md) | [العربية](README.ar.md) | [हिन्दी](README.hi.md)

---

## Qu'est-ce que Open Godot MCP ?

**Open Godot MCP** est un serveur [Model Context Protocol](https://modelcontextprotocol.io) open-source qui connecte les assistants de codage IA (Claude, GPT, Cursor, Windsurf, etc.) à l'éditeur [Godot Engine](https://godotengine.org). Il permet à l'IA **d'écrire du code, lancer le jeu, tester le gameplay, déboguer aux points d'arrêt, inspecter les variables et vérifier les corrections** — le tout de manière autonome, sans intervention humaine.

Contrairement aux serveurs Godot MCP existants qui ne font qu'éditer des scènes, Open Godot MCP permet à l'IA de **réellement jouer au jeu** grâce au playtesting déterministe (geler l'horloge → avancer le temps → observer l'état → vérifier le résultat). C'est le **seul** Godot MCP qui prend en charge les **tests de jeux multijoueur**, **l'intégration du débogueur DAP** et **l'intelligence de code LSP**.

| Attribut | Valeur |
|-----------|-------|
| **Type de projet** | Serveur MCP (Model Context Protocol) pour Godot Engine |
| **Moteur cible** | Godot 4.5+ (prise en charge GDScript + C#) |
| **Runtime** | Python 3.11+ (serveur) + GDScript (addon) |
| **Licence** | MIT (100% open source, pas de freemium) |
| **Outils** | ~30 outils MCP, ~130 actions |
| **Fonctionnalités clés** | Playtesting déterministe, tests multijoueur, débogage DAP, LSP, efficacité des tokens |
| **Clients IA** | Claude Desktop, Cursor, Windsurf, VS Code (MCP), Continue, Zed, tout client compatible MCP |
| **Plateformes** | Windows, macOS, Linux |
| **Capacités uniques** | Tests multijoueur (aucun autre Godot MCP ne l'a), intégration DAP + LSP |

---

## Pourquoi ce projet existe

Chaque Godot MCP sur le marché présente des lacunes :

| Problème | MCP existants | Open Godot MCP |
|---------|--------------|-----------------|
| L'IA ne peut pas voir le jeu réellement tourner | Édition uniquement, impossible de jouer au jeu pour corriger les bugs | **Playtesting déterministe** — geler l'horloge, avancer le temps précisément, step_until selon une condition |
| Connexion instable | Port codé en dur, pas de heartbeat, conflits WSL2 | Port configurable + heartbeat + reconnexion intelligente + évitement automatique de port |
| Impossible de tester le multijoueur | Tous les MCP manquent de tests multijoueur | **Unique** — multi-instance, simulation de pairs, vérification de synchronisation, injection de conditions réseau |
| Gaspillage de tokens | Retours complets, PNG non compressé, pas de diff | Observation économique, compression de captures d'écran, diff, résumés, requêtes incrémentales |
| Castration freemium | Version gratuite limitée, payer pour les fonctionnalités | **100% MIT open source**, toutes les fonctionnalités gratuites |

---

## À qui s'adresse ce projet ?

- **Développeurs de jeux utilisant Godot 4** qui veulent que l'IA les aide à écrire, tester et déboguer leurs jeux
- **Codeurs assistés par IA** (utilisateurs de Claude, Cursor, Windsurf, VS Code MCP) travaillant sur des projets Godot
- **Studios de jeux indépendants** qui ont besoin de playtesting automatisé sans écrire de framework de test
- **Développeurs de jeux multijoueur** qui doivent tester la synchronisation réseau, la latence et le comportement des pairs
- **Défenseurs de l'open source** qui veulent un serveur MCP entièrement gratuit sans paywall

---

## Cas d'usage

| Cas d'usage | Comment Open Godot MCP aide |
|----------|--------------------------|
| **L'IA corrige un bug de mouvement** | L'IA définit un point d'arrêt → lance le jeu → inspecte les variables → identifie la cause racine → corrige le code → re-teste |
| **Test automatisé de combat de boss** | Geler l'horloge → faire apparaître le boss → avancer le temps → simuler une entrée d'esquive → vérifier que le joueur survit |
| **Vérification de synchronisation multijoueur** | Lancer des instances hôte + client → injecter de la latence → comparer l'état de synchronisation → détecter les bugs de désynchronisation |
| **Profilage de performance** | Prendre un instantané du profiler → identifier le pic → optimiser → re-mesurer |
| **Tests de régression** | Exécuter la suite de tests après une modification de code → vérifier que l'état du jeu correspond à l'attendu |
| **Itération de design de niveau** | L'IA crée des nœuds → arrange la scène → lance le jeu → capture le résultat → ajuste |

---

## Capacités principales

### 1. Playtesting déterministe (résout « l'IA ne peut pas voir le jeu tourner »)

L'IA ne fait pas qu'écrire du code — elle peut **jouer au jeu elle-même pour vérifier les corrections** :

```
godot_game play frozen=true                    # Lancer le jeu (horloge gelée)
godot_exec eval code="GameState.wave = 3"      # Configurer un scénario de test
godot_game_time step_until "boss.size() >= 1"  # Attendre l'apparition du boss
godot_runtime_state digest                     # Observer l'état (JSON, sans tokens de vision)
godot_game_time step ms=500 + dodge input      # Jouer le moment critique
godot_screenshot game                          # Capture d'écran uniquement quand ça vaut le coup
```

### 2. Tests multijoueur (fonctionnalité unique — aucun autre Godot MCP ne l'a)

Une capacité qu'aucun Godot MCP existant ne possède :

```
godot_network launch_instance role="host"      # Démarrer le serveur
godot_network launch_instance role="client"    # Démarrer le client
godot_network network_condition latency=200    # Injecter 200 ms de latence
godot_network sync_state                       # Vérifier la synchronisation multi-instance
godot_network simulate_peer count=50           # Test de charge avec 50 pairs
```

### 3. Efficacité des tokens

Chaque outil intègre des mécanismes d'économie de tokens :

- **Observation économique** : le résumé d'état JSON remplace les captures d'écran (économise 90% des tokens)
- **Retours par diff** : ne renvoyer que les parties modifiées
- **Compression des captures d'écran** : JPEG/WebP + sauvegarde sur disque (pas dans le contexte)
- **Séparation lecture/écriture** : lecture auto-autorisée, écriture contrôlée
- **Opérations par lot** : effectuer plusieurs opérations en un seul aller-retour

### 4. Stabilité de connexion

Résout le problème « impossible de se connecter » des MCP existants :

- Port configurable (env > EditorSettings > évitement automatique)
- Détection de réservation de port Windows (éviter les ports réservés par Hyper-V/WSL2/Docker)
- Mécanisme de heartbeat (détection proactive des connexions mortes)
- Reconnexion intelligente (backoff exponentiel + nombre max de tentatives + notification UI)

### 5. Débogage complet

- **DAP (Debugger Adapter Protocol)** : points d'arrêt, exécution pas à pas, inspection de variables (stack_trace, variables, evaluate)
- **LSP (Language Server Protocol)** : diagnostics statiques, autocomplétion, go-to-definition
- **Profiler** : instantanés de performance, analyse de chronologie, détection de pics

---

## Démarrage rapide

### 1. Installer le serveur MCP

```bash
uv tool install open-godot-mcp
# ou
pip install open-godot-mcp
```

### 2. Configurer le client IA

```json
{
  "mcpServers": {
    "open-godot-mcp": {
      "command": "open-godot-mcp"
    }
  }
}
```

### 3. Ouvrir le projet Godot

L'addon s'injecte automatiquement. Ouvrez votre client IA et commencez à utiliser.

Guide d'installation complet : [Docs/06-Installation/Guide.md](Docs/06-Installation/Guide.md).

---

## Liste des outils

~30 outils, ~130 actions. Conception avec séparation lecture/écriture.

| Domaine | Outil | Description |
|--------|------|-------------|
| Éditeur | `godot_editor_read/edit` | État, scène, sélection |
| Scène | `godot_scene` | Créer, lire, sauvegarder |
| Nœud | `godot_node_read/edit` | CRUD, propriétés, groupes, signaux |
| Script | `godot_script` | Édition par diff, validation |
| Projet | `godot_project` | Paramètres, autoloads |
| Input Map | `godot_input_map` | Gestion de l'InputMap |
| Ressource | `godot_resource` | Inspection consciente des types |
| Animation | `godot_animation` | Créer, pistes, préréglages |
| TileMapLayer | `godot_tilemap` | Lecture/écriture des cellules |
| **Contrôle du jeu** | `godot_game` | play/stop/freeze |
| **Horloge** | `godot_game_time` | freeze/step/step_until |
| **Entrée** | `godot_input` | Clavier/souris/manette/texte |
| **État** | `godot_runtime_state` | digest/watch/signals |
| **Injection** | `godot_exec` | eval/call/assert |
| Capture d'écran | `godot_screenshot` | Compression, sauvegarde dans un fichier |
| Débogueur | `godot_debugger` | Points d'arrêt DAP, stack_trace, variables, evaluate |
| Code | `godot_lsp` | Diagnostics, complétion |
| Profiler | `godot_profiler` | Instantanés, chronologie |
| Test | `godot_test` | Framework, exécution |
| **Réseau** | `godot_network` | Multi-instance, synchronisation, conditions réseau |
| Instance | `godot_instance` | Gestion multi-Godot |
| Système de fichiers | `godot_filesystem` | Lecture/écriture, recherche |
| Docs | `godot_docs` | Correspondance de version |
| Journal | `godot_log` | Requête incrémentale |
| Lot | `godot_batch` | Plusieurs opérations à la fois |
| Asset | `godot_asset` | Génération, gestion |
| Export | `godot_export` | Préréglages, export |
| Santé | `godot_health` | Vérification de connexion |

API complète : [Docs/02-Tools/Index.md](Docs/02-Tools/Index.md).

---

## Comparaison avec les serveurs Godot MCP existants

| Fonctionnalité | godot-ai | godot-mcp | Coding-Solo | satelliteoflove | thediymaker | **Open Godot MCP** |
|---------|----------|-----------|-------------|-----------------|-------------|---------------------|
| Opérations éditeur | ✅ | ✅ | ✅ | ✅ | ✅ 149 outils | ✅ |
| Contrôle réel du jeu | ⚠️ | ⚠️ | ❌ | ✅ déterministe | ⚠️ | ✅ **déterministe+temps réel** |
| Tests multijoueur | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ **unique** |
| Débogage DAP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Intégration LSP | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Efficacité des tokens | ⚠️ | ⚠️ | ❌ | ✅ | ❌ | ✅ **complet** |
| Stabilité de connexion | ⚠️ | ❌ | — | ✅ | — | ✅ **le plus stable** |
| Licence | open | open | MIT | MIT | MIT | **MIT** |

---

## FAQ

### Qu'est-ce que le Model Context Protocol (MCP) ?

Le [Model Context Protocol](https://modelcontextprotocol.io) est une norme ouverte qui permet aux assistants IA de se connecter à des outils et sources de données externes. Open Godot MCP est un serveur MCP qui connecte l'IA à l'éditeur Godot Engine.

### Quelles versions de Godot sont prises en charge ?

Godot 4.5 et plus récent. L'addon utilise les API de Godot 4.x, notamment `EditorDebuggerPlugin`, `EditorInspector` et le canal de messages du débogueur.

### Quels clients IA sont compatibles ?

Tout client compatible MCP : Claude Desktop, Cursor, Windsurf, VS Code (avec l'extension MCP), Continue, Zed, et tout client qui prend en charge la norme Model Context Protocol.

### Prend-il en charge C# (la version .NET de Godot) ?

Oui. La vérification de syntaxe C# et la vérification de compilation sont prises en charge. Voir [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/).

### En quoi est-ce différent des autres serveurs Godot MCP ?

Open Godot MCP est le **seul** Godot MCP qui prend en charge les tests de jeux multijoueur, l'intégration du débogueur DAP (points d'arrêt, traces de pile, inspection de variables) et l'intelligence de code LSP. Il possède également la conception d'efficacité de tokens la plus complète.

### Est-ce vraiment gratuit ?

Oui. 100% sous licence MIT, pas de modèle freemium, pas de paywall, pas de restriction de fonctionnalités. Toutes les fonctionnalités sont gratuites pour tout le monde.

### L'IA peut-elle réellement jouer au jeu ?

Oui. Grâce au playtesting déterministe, l'IA peut geler l'horloge du jeu, avancer le temps par incréments précis, injecter des scénarios de test, simuler des entrées du joueur, observer l'état du jeu en JSON et prendre des captures d'écran — le tout pour vérifier que les modifications de code fonctionnent correctement.

### Comment fonctionnent les tests multijoueur ?

Open Godot MCP peut lancer plusieurs instances Godot (hôte + clients), simuler des pairs, injecter des conditions réseau (latence, perte de paquets) et vérifier que l'état du jeu est synchronisé entre les instances.

---

## Documentation

Index complet de la documentation : [Docs/README.md](Docs/README.md). Découplé par dossier.

| Dossier | Contenu |
|--------|---------|
| [Docs/00-Overview/](Docs/00-Overview/) | Aperçu des fonctionnalités, philosophie de conception |
| [Docs/01-Architecture/](Docs/01-Architecture/) | Architecture, protocole, stabilité de connexion, multi-instance, runtime |
| [Docs/02-Tools/](Docs/02-Tools/) | Liste complète des outils (fichiers par domaine) |
| [Docs/03-Realtime-Testing/](Docs/03-Realtime-Testing/) | Playtesting déterministe (Guide + Exemples) |
| [Docs/04-Token-Efficiency/](Docs/04-Token-Efficiency/) | Conception d'économie de tokens (Guide + Stratégies) |
| [Docs/05-Network-Testing/](Docs/05-Network-Testing/) | Tests multijoueur (Guide + Exemples) |
| [Docs/06-Installation/](Docs/06-Installation/) | Installation (Guide + Dépannage) |
| [Docs/07-Roadmap/](Docs/07-Roadmap/) | Feuille de route de développement |
| [Docs/08-CSharp-Support/](Docs/08-CSharp-Support/) | Compatibilité C# Godot & vérification de syntaxe |
| [Docs/09-Research/](Docs/09-Research/) | Recherche sur les MCP existants, recherche MCP C# |

---

## Remerciements

Open Godot MCP s'appuie sur des géants, en tirant le meilleur de :

- [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp) (4.8k étoiles) — architecture fondamentale
- [satelliteoflove/godot-mcp](https://github.com/satelliteoflove/godot-mcp) — playtesting déterministe, observation économique, séparation lecture/écriture
- [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai) — canal de débogueur runtime, Undo/Redo, réservation de port Windows, 20+ configurations de clients, McpTestSuite
- [tomyud1/godot-mcp](https://github.com/tomyud1/godot-mcp) — architecture double canal, sérialisation Variant, protection contre la suppression
- [rosskarchner/godot-mcp](https://github.com/rosskarchner/godot-mcp) — intégration DAP + LSP, multi-instance, isolation de port
- [Erodenn/godot-mcp-runtime](https://github.com/Erodenn/godot-mcp-runtime) — empreinte zéro, concept Playwright pour Godot
- [thediymaker/godot-mcp](https://github.com/thediymaker/godot-mcp) — référence d'étendue avec 149 outils

---

## Licence

[MIT](LICENSE) — 100% open source, toutes les fonctionnalités gratuites, pas de freemium, pas de paywall.
