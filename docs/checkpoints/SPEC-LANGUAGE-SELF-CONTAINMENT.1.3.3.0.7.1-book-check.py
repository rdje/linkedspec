"""Verify twelve measured sources and current provenance teaching in rendered mdBook."""
import hashlib
import html
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
SOURCE = "docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md"
source = (ROOT / SOURCE).read_text()
rendered = ROOT / "docs/linkedspec-book/book/dsl/actionir-lowering-mental-model.html"
plain = html.unescape(re.sub(r"<[^>]*>", "", rendered.read_text()))
cases = {row["id"]: row for row in json.loads((ROOT / (PREFIX + "cases.json")).read_bytes())}
cases.update({row["id"]: row for row in json.loads((ROOT / (PREFIX + "keyword-cases.json")).read_bytes())})
cases.update({row["id"]: row for row in json.loads((ROOT / (PREFIX + "span-cases.json")).read_bytes())})
cases.update({row["id"]: row for row in json.loads((ROOT / (PREFIX + "compatibility-cases.json")).read_bytes())})
examples = []
for name in ("assignment_raw", "assignment_canonical", "codeblock_body_raw",
             "comment_data", "repeated_raw", "blind_edge_raw", "bridge_keyword_deferred", "bridge_keyword_effects", "mark",
             "emit_context_canonical_action_ir_lowers_call_wrappers_without_raw_fallback",
             "method_empty_action_return_with_leading_space_args_stays_balanced",
             "spec_format_terse_3_3_3_mutation_assignment_expression_values"):
    text = cases[name]["source"]
    if text not in source or text not in plain:
        raise ValueError("measured source missing: " + name)
    examples.append({"id": name, "source_sha256": hashlib.sha256(text.encode()).hexdigest()})
compact = re.sub(r"\s+", " ", plain)
for phrase in ("ready0/raw1/fallback0", "raw_perl_expression_dependencies",
               "raw_perl_expression_source_units", "not the absolute .spec file",
               "same spelling as the generated bridge", "does not scan the function registry",
               "false portability blocker", "unsupported_codeblock_actionir",
               "it is not an execution trace", "user_function_keyword_arguments_unsupported",
               "rejection occurs before either operand executes", "Unicode-scalar",
               "An authored identical chunk", "does not remove prior canonical fallback events", "ready0/raw2/fallback0",
               "Bare return and exit payloads are inspected independently",
               "grouped assignments inside deferred codeblocks raw"):
    if phrase not in compact:
        raise ValueError("reporting contract missing: " + phrase)
print(json.dumps({"owner": OWNER, "result": "PASS", "examples": examples,
                  "source": SOURCE, "source_sha256": hashlib.sha256((ROOT / SOURCE).read_bytes()).hexdigest(),
                  "limits": "Twelve exact measured source identities and rendered reporting/provenance teaching; two keyword controls are typed failures, not syntax admission. No other-backend or complete composed execution admission."}, indent=2))
