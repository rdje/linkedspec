"""Check four executed raw/canonical/data sources in authored and rendered teaching."""
import hashlib
import html
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0"
SOURCE = "docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md"
source = (ROOT / SOURCE).read_text()
rendered = ROOT / "docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html"
plain = html.unescape(re.sub(r"<[^>]*>", "", rendered.read_text()))
cases = {row["id"]: row for row in json.loads(
    (ROOT / ("docs/checkpoints/" + OWNER + "-cases.json")).read_bytes())}
examples = []
for name in ("assignment_raw", "assignment_canonical", "codeblock_body_raw", "comment_data"):
    text = cases[name]["source"]
    if text not in source or text not in plain:
        raise ValueError("executed source missing: " + name)
    examples.append({"id": name, "source_sha256": hashlib.sha256(text.encode()).hexdigest()})
compact = re.sub(r"\s+", " ", plain)
for phrase in ("known defect", "one source occurrence", "false portability blocker",
               "No shipped-spec census", "unsupported_codeblock_actionir"):
    if phrase not in compact:
        raise ValueError("diagnostic boundary missing: " + phrase)
print(json.dumps({"owner": OWNER, "result": "PASS", "examples": examples,
                  "source": SOURCE, "source_sha256": hashlib.sha256((ROOT / SOURCE).read_bytes()).hexdigest(),
                  "limits": "Four exact executed source identities and bounded diagnostic teaching; no layout, new runtime or other-backend admission."}, indent=2))
