"""Check complete Knowledge projection semantics and a public-generator fixture."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent


def projection(text):
    prefix, body = text.split("## Facts (by id)\n", 1)
    chunks = re.split(r"(?m)^### ([^\n]+)\n", body)
    if chunks[0].strip() or len(chunks) % 2 != 1:
        raise ValueError("malformed fact section")
    facts = {}
    order = []
    for index in range(1, len(chunks), 2):
        identity, content = chunks[index:index + 2]
        if identity in facts:
            raise ValueError("duplicate fact identity")
        fields = {}
        title = None
        for line in content.splitlines():
            if not line:
                continue
            if line.startswith("_") and line.endswith("_") and title is None:
                title = line
                continue
            match = re.fullmatch(r"- \*\*(answers|date|evidence|reverify|source):\*\* (.*)", line)
            if not match:
                raise ValueError("unrecognized fact content")
            key, value = match.groups()
            if key == "date" and " · **source:** " in value:
                value, source = value.rsplit(" · **source:** ", 1)
                if "source" in fields:
                    raise ValueError("duplicate source")
                fields["source"] = source
            if key in fields:
                raise ValueError("duplicate field")
            fields[key] = value
        if title is None or not {"answers", "date", "source"} <= fields.keys():
            raise ValueError("missing required fact metadata")
        facts[identity] = {"title": title, "fields": fields}
        order.append(identity)
    return {"prefix": prefix, "order": order, "facts": facts}


def compare(before, after):
    if projection(before) != projection(after):
        raise ValueError("question routing or fact metadata changed")


def controls(reference, candidate):
    compare(reference, candidate)
    mutations = {
        "question": re.sub(r'(?m)^- ".*? -> .*\n', "", candidate, count=1),
        "title": re.sub(r"(?m)^_(.+)_$", r"_CORRUPTED \1_", candidate, count=1),
    }
    for field in ("answers", "date", "evidence", "reverify", "source"):
        mutations[field] = candidate.replace("**" + field + ":** ", "**" + field + ":** CORRUPTED ", 1)
    rejected = []
    for name, changed in mutations.items():
        if changed == candidate:
            raise ValueError("missing mutation target: " + name)
        try:
            compare(reference, changed)
        except ValueError:
            rejected.append(name)
        else:
            raise ValueError("accepted changed projection: " + name)
    return rejected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--compare", nargs=2, type=Path)
    parser.add_argument("--evidence", type=Path)
    args = parser.parse_args()
    for path in (args.compare or []) + ([args.evidence] if args.evidence else []):
        if path.is_absolute() or ".." in path.parts:
            parser.error("paths must be repository-relative")
    if args.evidence and (not args.evidence.parts or args.evidence.parts[0] != ".linkedspec-data"):
        parser.error("evidence must be beneath .linkedspec-data")
    fixture = None
    if args.compare:
        before, after = [path.read_text() for path in args.compare]
    else:
        with tempfile.TemporaryDirectory(prefix="knowledge-projection-", dir=os.environ["LINKEDSPEC_RUN_DIR"]) as name:
            scratch = Path(name)
            facts = scratch / "facts"
            facts.mkdir()
            source = facts / "sample.md"
            fixture = """---
id: projection-sample
title: Projection sample
answers:
  - z question
  - a question
  - a question
date: 2026-11-01
status: current
evidence: [first.md, second.md]
reverify: [printf first, printf second]
---

Canonical body.
"""
            source.write_text(fixture)
            output = scratch / "map.md"
            env = dict(os.environ, KM_SCAN_DIRS=str(facts.relative_to(ROOT)),
                       KM_OUTPUT=str(output.relative_to(ROOT)), KM_TITLE="Projection fixture")
            result = subprocess.run(["bash", "knowledge-map/scripts/gen_knowledge_map.sh"],
                                    cwd=ROOT, env=env, capture_output=True, check=True)
            after = output.read_text()
            actual = projection(after)
            tick = chr(96)
            path = str(source.relative_to(ROOT))
            expected = {"title": "_Projection sample_", "fields": {
                "answers": "z question | a question | a question",
                "date": "2026-11-01 · **status:** current",
                "evidence": f"{tick}first.md{tick} · {tick}second.md{tick}",
                "reverify": f"{tick}printf first{tick} · {tick}printf second{tick}",
                "source": f"[{tick}{path}{tick}]({path})"}}
            if actual["facts"] != {"projection-sample": expected}:
                raise ValueError("fixture metadata differs from authored oracle")
            questions = [line for line in actual["prefix"].splitlines() if line.startswith('- "')]
            expected_questions = [
                f'- "{q}" -> [projection-sample]({path}) · 2026-11-01 · reverify: [2 entries](#projection-sample)'
                for q in ("a question", "z question")]
            if questions != expected_questions:
                raise ValueError("fixture routes or list pointer changed")
            before = after
    rejected = controls(before, after)
    parsed = projection(after)
    report = {"facts": len(parsed["facts"]), "semantic_preservation": True,
              "rejected_mutations": rejected, "fixture": fixture,
              "before_sha256": hashlib.sha256(before.encode()).hexdigest(),
              "after_sha256": hashlib.sha256(after.encode()).hexdigest(),
              "after_lines": len(after.splitlines()), "after_bytes": len(after.encode())}
    if args.evidence:
        args.evidence.write_text(json.dumps(report, sort_keys=True) + "\n")
    print(json.dumps(report, sort_keys=True))


if __name__ == "__main__":
    main()
