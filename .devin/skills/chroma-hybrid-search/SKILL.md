---
name: chroma-hybrid-search
description: "Local hybrid retrieval (BM25 + ChromaDB vector + BGE-Reranker) over ~/.deep-memory hot and cold stores. Use when high-accuracy code/solution retrieval is needed and hallucination must be minimized. Typically invoked by deep-memory."
---

# Chroma Hybrid Search Skill

> **Cross-platform command convention** — `<PY>` is the global workspace venv Python:
> - Windows PowerShell: `& "$HOME\.deep-memory\.venv\Scripts\python"`
> - Linux/macOS: `~/.deep-memory/.venv/bin/python`
>
> Default workspace: `~/.deep-memory`. Override with `--workspace` or `DEEP_MEMORY_WORKSPACE`.
>
> **Repo-local script path** (this repo): `.devin/skills/chroma-hybrid-search/scripts/`.
> When synced into a tool, the canon points here. The scripts are self-contained and
> operate on `~/.deep-memory/` (user-global), not the repo.

## First-Time Bootstrap

If `~/.deep-memory/.venv` does not exist:

```bash
# Windows
python -m venv "$HOME\.deep-memory\.venv"
# Linux/macOS
python3 -m venv ~/.deep-memory/.venv

# Install deps (path is relative to this repo root)
<PY> -m pip install -r .devin/skills/chroma-hybrid-search/requirements.txt

# Build index
<PY> .devin/skills/chroma-hybrid-search/scripts/update_db.py
```

## Usage

### Hybrid (default)
```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "spring animation tuning" --limit 3 --min-score 0.35
```

### Vector only
```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "..." --mode vector --limit 3
```

### BM25 only
```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "KEY_xxx" --mode bm25 --limit 3
```

### Scoped by skill or tag
```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "session timeout" --skill backend-dev
<PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "config drift" --tag redis
```

## Output

JSON array:
```json
[
  {
    "path": "experience/skill-remotion-best-practices.md#fps-30-causes-av-desync",
    "rerank_score": 0.9402,
    "text": "## FPS 30 causes A/V desync\n..."
  }
]
```

> Use the `text` field directly. Do not read the whole source file at `path` — that defeats chunking.

## Anti-Hallucination

- Always pass `--min-score 0.35` in hybrid mode.
- Below-threshold results are dropped.
- If 0 hits, continue without hallucinated context.

## Writing cold notes

```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/write_cold.py \
  --text "When editing large CSVs, use Python csv module, not edit tool." \
  --tags "csv,big-file" --project "agent-harness-deploy"
```

After writing, rebuild the index:
```bash
<PY> .devin/skills/chroma-hybrid-search/scripts/update_db.py
```
