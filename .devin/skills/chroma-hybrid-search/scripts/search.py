#!/usr/bin/env python3
"""Repo-local deep-memory hybrid search.

Usage (from repo root):
    <PY> .devin/skills/chroma-hybrid-search/scripts/search.py --query "..." --limit 3 --min-score 0.35

Operates on ~/.deep-memory/ (user-global workspace). Override with --workspace or
DEEP_MEMORY_WORKSPACE. Self-contained — no external skill paths required.

v1.0 | 2026-07-07
"""

import argparse
import json
import os
import sys
from pathlib import Path


# Reconfigure stdout for UTF-8 to avoid UnicodeEncodeError on Windows cp950.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")


def set_console_utf8() -> None:
    """Set Windows console output code page to UTF-8 (65001) if possible."""
    try:
        import ctypes
        ctypes.windll.kernel32.SetConsoleOutputCP(65001)
    except Exception:
        pass


set_console_utf8()


def workspace_path(workspace: str | None) -> Path:
    if workspace:
        return Path(workspace).expanduser().resolve()
    env = os.environ.get("DEEP_MEMORY_WORKSPACE")
    if env:
        return Path(env).expanduser().resolve()
    return Path.home() / ".deep-memory"


def load_corpus_for_bm25(ws: Path) -> list[dict]:
    """Load all docs for BM25 from hot + cold stores."""
    docs = []
    kb_dir = ws / "knowledge-base"
    exp_dir = ws / "experience"
    for d in [kb_dir, exp_dir]:
        if not d.exists():
            continue
        for md in sorted(d.glob("*.md")):
            text = md.read_text(encoding="utf-8")
            docs.append({
                "id": md.name + "#whole",
                "text": text,
                "metadata": {"source": str(md), "type": "hot", "project": "*"},
            })
    raw = ws / "cold-notes" / "raw.jsonl"
    if raw.exists():
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
                docs.append({
                    "id": obj.get("project", "cold") + "-" + str(len(docs)),
                    "text": text,
                    "metadata": {
                        "source": str(raw),
                        "type": "cold",
                        "project": obj.get("project", ""),
                        "date": obj.get("date", ""),
                        "tags": ",".join(obj.get("tags", [])),
                    },
                })
    return docs


def bm25_search(query: str, corpus: list[dict], top_k: int) -> list[tuple[int, float]]:
    try:
        from rank_bm25 import BM25Okapi
    except ImportError:
        return []
    tokenized = [d["text"].lower().split() for d in corpus]
    bm25 = BM25Okapi(tokenized)
    scores = bm25.get_scores(query.lower().split())
    top = sorted(enumerate(scores), key=lambda x: x[1], reverse=True)[:top_k]
    return top


def vector_search(query: str, collection, top_k: int, where: dict | None) -> list[dict]:
    try:
        from sentence_transformers import SentenceTransformer
    except ImportError:
        return []
    model = SentenceTransformer("BAAI/bge-small-en-v1.5")
    raw_embedding = model.encode([query], show_progress_bar=False)
    embedding = raw_embedding.tolist() if hasattr(raw_embedding, "tolist") else list(raw_embedding)
    results = collection.query(
        query_embeddings=embedding,
        n_results=top_k,
        where=where,
        include=["documents", "metadatas", "distances"],
    )
    out = []
    for ids, docs, metas, dists in zip(
        results["ids"], results["documents"], results["metadatas"], results["distances"]
    ):
        for i, doc_id in enumerate(ids):
            score = max(0.0, 1.0 - dists[i])
            out.append({
                "id": doc_id,
                "text": docs[i],
                "metadata": metas[i],
                "score": score,
            })
    return out


def rerank(query: str, candidates: list[dict], top_k: int):
    try:
        from sentence_transformers import CrossEncoder
    except ImportError:
        return candidates[:top_k]
    model = CrossEncoder("BAAI/bge-reranker-base")
    pairs = [(query, c["text"]) for c in candidates]
    scores = model.predict(pairs, show_progress_bar=False)
    for c, s in zip(candidates, scores):
        c["rerank_score"] = float(s)
    ranked = sorted(candidates, key=lambda x: x["rerank_score"], reverse=True)
    return ranked[:top_k]


def main():
    parser = argparse.ArgumentParser(description="Hybrid search over Deep-Memory.")
    parser.add_argument("--query", required=True, help="Search query.")
    parser.add_argument("--limit", type=int, default=3, help="Number of results.")
    parser.add_argument("--min-score", type=float, default=0.35, help="Minimum rerank score.")
    parser.add_argument("--mode", choices=["hybrid", "vector", "bm25"], default="hybrid", help="Search mode.")
    parser.add_argument("--workspace", default=None, help="Override workspace path.")
    parser.add_argument("--skill", default=None, help="Filter by skill id.")
    parser.add_argument("--tag", default=None, help="Filter by tag.")
    args = parser.parse_args()

    ws = workspace_path(args.workspace)
    project = Path.cwd().name

    try:
        import chromadb
    except ImportError:
        print(json.dumps([{"error": "chromadb not installed. Run requirements install first."}], ensure_ascii=False))
        return

    client = chromadb.PersistentClient(path=str(ws / "chroma_hybrid_db"))
    collection = client.get_or_create_collection(name="deep_memory")

    candidates = []

    if args.mode in ("hybrid", "vector"):
        where = None
        if args.skill:
            where = {"skill": args.skill}
        elif args.tag:
            where = {"tags": {"$contains": args.tag}}
        vec_results = vector_search(args.query, collection, args.limit * 3, where)
        for r in vec_results:
            r["source"] = "vector"
        candidates.extend(vec_results)

    if args.mode in ("hybrid", "bm25"):
        corpus = load_corpus_for_bm25(ws)
        bm25_results = bm25_search(args.query, corpus, args.limit * 3)
        for idx, score in bm25_results:
            doc = corpus[idx]
            candidates.append({
                "id": doc["id"],
                "text": doc["text"],
                "metadata": doc["metadata"],
                "score": score,
                "source": "bm25",
            })

    seen = set()
    unique = []
    for c in candidates:
        if c["id"] in seen:
            continue
        seen.add(c["id"])
        unique.append(c)

    if not unique:
        print(json.dumps([], ensure_ascii=False))
        return

    ranked = rerank(args.query, unique, args.limit * 2)

    if args.mode == "hybrid":
        project_hits = [r for r in ranked if r.get("metadata", {}).get("project") in (project, "*", "")]
        other_hits = [r for r in ranked if r.get("metadata", {}).get("project") not in (project, "*", "")]
        ranked = project_hits + other_hits

    final = [r for r in ranked if r.get("rerank_score", 0.0) >= args.min_score][:args.limit]

    output = []
    for r in final:
        meta = r.get("metadata", {})
        source = meta.get("source", "")
        entry = meta.get("entry", "")
        path = source
        if entry:
            path += f"#{entry}"
        output.append({
            "path": path,
            "rerank_score": r.get("rerank_score", 0.0),
            "text": r["text"],
            "metadata": meta,
        })

    print(json.dumps(output, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
