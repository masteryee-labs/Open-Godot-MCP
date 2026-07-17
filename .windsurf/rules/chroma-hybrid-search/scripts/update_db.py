#!/usr/bin/env python3
"""Build/update the local ChromaDB vector index from hot and cold stores.

Usage (from repo root):
    <PY> .windsurf/rules/chroma-hybrid-search/scripts/update_db.py
    <PY> .windsurf/rules/chroma-hybrid-search/scripts/update_db.py --workspace ~/.deep-memory

Operates on ~/.deep-memory/ (user-global). Self-contained.
"""

import argparse
import hashlib
import json
import os
import re
from pathlib import Path


def workspace_path(workspace: str | None) -> Path:
    if workspace:
        return Path(workspace).expanduser().resolve()
    env = os.environ.get("DEEP_MEMORY_WORKSPACE")
    if env:
        return Path(env).expanduser().resolve()
    return Path.home() / ".deep-memory"


def split_md_entries(path: Path) -> list[dict]:
    """Split a markdown file on '## ' headings (entry-level chunking)."""
    if not path.exists():
        return []
    text = path.read_text(encoding="utf-8")
    if "## " not in text:
        return [{"id": f"{path.name}#whole", "text": text, "metadata": {"source": str(path), "entry": "whole"}}]

    parts = re.split(r"\n##\s+", text)
    entries = []
    for i, part in enumerate(parts[1:], start=1):
        lines = part.strip().splitlines()
        title = lines[0].strip() if lines else f"entry-{i}"
        slug = re.sub(r"[^\w\-]+", "-", title).strip("-").lower()[:60]
        entry_text = f"## {part.strip()}"
        entries.append({
            "id": f"{path.name}#{slug}",
            "text": entry_text,
            "metadata": {"source": str(path), "entry": slug},
        })
    return entries


def load_hot_store(ws: Path) -> list[dict]:
    docs = []
    kb_dir = ws / "knowledge-base"
    exp_dir = ws / "experience"
    for d in [kb_dir, exp_dir]:
        if not d.exists():
            continue
        for md in sorted(d.glob("*.md")):
            for entry in split_md_entries(md):
                entry["metadata"]["type"] = "hot"
                entry["metadata"]["project"] = "*"
                docs.append(entry)
    return docs


def load_cold_store(ws: Path) -> list[dict]:
    raw = ws / "cold-notes" / "raw.jsonl"
    docs = []
    if not raw.exists():
        return docs
    with open(raw, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            text = obj.get("text", "")
            if not text:
                continue
            entry_id = hashlib.md5(line.encode("utf-8")).hexdigest()[:16]
            docs.append({
                "id": f"cold-{entry_id}",
                "text": text,
                "metadata": {
                    "type": "cold",
                    "project": obj.get("project", ""),
                    "date": obj.get("date", ""),
                    "tags": ",".join(obj.get("tags", [])),
                    "source": str(raw),
                },
            })
    return docs


def main():
    parser = argparse.ArgumentParser(description="Update Deep-Memory vector index.")
    parser.add_argument("--workspace", default=None, help="Override workspace path.")
    parser.add_argument("--model", default="BAAI/bge-small-en-v1.5", help="Embedding model.")
    args = parser.parse_args()

    ws = workspace_path(args.workspace)
    print(f"[update-db] workspace: {ws}")

    docs = load_hot_store(ws) + load_cold_store(ws)
    if not docs:
        print("[update-db] no documents found. Run write_cold.py first.")
        return

    print(f"[update-db] loaded {len(docs)} chunks")

    try:
        import chromadb
        from sentence_transformers import SentenceTransformer
    except ImportError as e:
        print(f"[update-db] missing dependency: {e}")
        print("[update-db] run: <PY> -m pip install -r .windsurf/rules/chroma-hybrid-search/requirements.txt")
        return

    client = chromadb.PersistentClient(path=str(ws / "chroma_hybrid_db"))
    collection = client.get_or_create_collection(name="deep_memory")

    model = SentenceTransformer(args.model)
    print(f"[update-db] embedding model: {args.model}")

    batch_size = 64
    for i in range(0, len(docs), batch_size):
        batch = docs[i:i + batch_size]
        ids = [d["id"] for d in batch]
        texts = [d["text"] for d in batch]
        metadatas = [d["metadata"] for d in batch]
        raw_embeddings = model.encode(texts, show_progress_bar=False)
        embeddings = raw_embeddings.tolist() if hasattr(raw_embeddings, "tolist") else list(raw_embeddings)
        collection.add(ids=ids, documents=texts, metadatas=metadatas, embeddings=embeddings)
        print(f"[update-db] indexed batch {i//batch_size + 1}/{(len(docs)-1)//batch_size + 1}")

    print(f"[update-db] done. Total indexed: {len(docs)}")


if __name__ == "__main__":
    main()
