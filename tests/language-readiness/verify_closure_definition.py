"""Revision-bound closure reconciliation; no grammar execution or admission.

Run after the local book build with tools/run_python_project_data.sh. This audit
uses committed baselines, matrix rows and Python syntax trees, rather than importing
the production closure validator or deriving an expected schema from its output.
"""

import ast
import copy
import hashlib
import json
from functools import cache
from html.parser import HTMLParser
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parents[2]
STRUCTURE = "e4f9dcb8d6ee825119863d076d5a32be42ab9ef6"
POLICY = "4b16791ad67aee14b7ae53ef426957a9c074beac"
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4"
CONTRACT = "capability_conformance/language_closure_contract.json"
MATRIX = "docs/language-readiness/closure-contract-matrix.md"
CHECKER = "tools/check_language_closure_contract.py"
BOOK = "docs/linkedspec-book/src/architecture/structured-format-program.md"
HTML = "docs/linkedspec-book/book/architecture/structured-format-program.html"
RUNTIME_BOOK = "docs/linkedspec-book/src/appendix/runtime-semantics.md"
RUNTIME_HTML = "docs/linkedspec-book/book/appendix/runtime-semantics.html"
BOOK_CLAIMS = (
    "Definition reconciliation preserves the original 66 bindings and all 90 policy anchors.",
    "Structural closure is complete; composed objective execution remains pending.",
    "Known repair prerequisites remain mandatory before dependent promotion.",
    "This closeout establishes no new runtime admission or sandbox guarantee.",
)
POLICY_BOOK_CLAIMS = (
    "90 semantic anchors", "all 66 original bindings",
    "Cancellation, deadline, remaining budget and sink behavior are operational inputs.",
    "same-rule/same-position cutoff", "supplementary-character order exception",
    "The receiver was already committed", "default ambient-isolation or sandbox proof",
)
RUNTIME_CLAIMS = (
    "null last_error", "no admitted configurable 100–1000 threshold",
    "Owner-Specific Structured Diagnostics", "Result<Value, String>", "[9,1]",
    "index 2 precedes index 10", "no universal user-state or AST rollback",
    "No timing-independent outcome",
)


def require(condition, reason):
    if not condition:
        raise ValueError(reason)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_relative(path):
    candidate = Path(path)
    require(not candidate.is_absolute() and ".." not in candidate.parts, "path boundary")
    resolved = ROOT / candidate
    require(all(not part.is_symlink() for part in (resolved, *resolved.parents)), "path symlink")
    resolved.resolve().relative_to(ROOT)
    return resolved.read_bytes()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


@cache
def committed(commit, path):
    return git("show", f"{commit}:{path}")


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        require(key not in result, "duplicate JSON key")
        result[key] = value
    return result


def load(data):
    def reject(value):
        raise ValueError(f"nonfinite JSON: {value}")
    return json.loads(data, object_pairs_hook=unique_object, parse_constant=reject)


def canonical(value):
    return json.dumps(value, ensure_ascii=False, sort_keys=True,
                      separators=(",", ":"), allow_nan=False).encode()


def matrix_rows(data):
    rows = {}
    for line in data.decode().splitlines():
        match = re.fullmatch(r"\| `([^`]+_contract.json)` \| `([^`]+)` \| (.+) \|", line)
        if match:
            name = match[1].removesuffix("_contract.json")
            require(name not in rows, "matrix duplicate")
            rows[name] = (match[2], re.findall(r"`(/[^`]+)`", match[3]))
    require(len(rows) == 16, "matrix rows")
    return rows


def assignment(data, name):
    nodes = [node.value for node in ast.parse(data).body
             if isinstance(node, ast.Assign)
             and any(isinstance(target, ast.Name) and target.id == name for target in node.targets)]
    require(len(nodes) == 1 and isinstance(nodes[0], ast.Dict), f"register {name}")
    keys = [ast.literal_eval(key) for key in nodes[0].keys]
    require(len(keys) == len(set(keys)), f"register duplicate {name}")
    return nodes[0]


def register(data, name):
    return ast.literal_eval(assignment(data, name))


def check_policy_schema(data):
    """Compare syntax without evaluating comprehensions or importing the checker."""
    current = assignment(data, "FIXED_SECTIONS")
    baseline = assignment(committed(POLICY, CHECKER), "FIXED_SECTIONS")
    stage = current.values[[ast.literal_eval(key) for key in current.keys].index("stage")]
    index = [ast.literal_eval(key) for key in stage.keys].index("independent_reconciliation")
    require(ast.literal_eval(stage.values[index]) == "complete", "checker reconciliation stage")
    stage.values[index] = ast.Constant("pending_SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4")
    require(ast.dump(current) == ast.dump(baseline), "checker policy schema drift")


class MainText(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_main = False
        self.parts = []

    def handle_starttag(self, tag, attrs):
        if tag == "main":
            self.in_main = True

    def handle_endtag(self, tag):
        if tag == "main":
            self.in_main = False

    def handle_data(self, data):
        if self.in_main:
            self.parts.append(data)


def rendered_text(data):
    parser = MainText()
    parser.feed(data.decode())
    return " ".join(" ".join(parser.parts).split())


def audit(read=read_relative):
    old = load(committed(STRUCTURE, CONTRACT))
    policy = load(committed(POLICY, CONTRACT))
    current = load(read(CONTRACT))
    require(current.get("reconciliation_owner") == OWNER, "reconciliation owner")
    require(current["stage"]["independent_reconciliation"] == "complete", "reconciliation stage")
    normalized = copy.deepcopy(current)
    del normalized["reconciliation_owner"]
    normalized["stage"]["independent_reconciliation"] = policy["stage"]["independent_reconciliation"]
    require(canonical(normalized) == canonical(policy), "policy baseline drift")
    rows = matrix_rows(read(MATRIX))
    require(rows == matrix_rows(committed(STRUCTURE, MATRIX)), "original matrix drift")
    authority_register = register(read(CHECKER), "AUTHORITY_REGISTER")
    require(set(authority_register) == set(rows) == set(current["authorities"]), "authority register keys")
    sources = {}
    original = additional = 0
    for name, row in current["authorities"].items():
        identity, pointers = rows[name]
        require(row["contract_id"] == identity, f"matrix identity {name}")
        require(set(pointers) == set(old["authorities"][name]["semantic_sha256"]), f"original pointers {name}")
        require(all(row["semantic_sha256"].get(p) == h for p, h in
                    old["authorities"][name]["semantic_sha256"].items()), f"original binding {name}")
        suffix, registered = authority_register[name]
        expected_owner = "FUTURE-PARITY-BACKLOG." + suffix if suffix[0].isdigit() else suffix
        require(row["proof_owner"] == expected_owner, f"register owner {name}")
        require(set(registered.split()) == set(row["semantic_sha256"]), f"register pointers {name}")
        data = read(row["path"])
        require(data == committed(STRUCTURE, row["path"])
                == committed(POLICY, row["path"]), f"authority bytes {name}")
        source = load(data)
        require(source["contract_id"] == identity and type(source["format"]) is int
                and source["format"] == 1, f"source identity {name}")
        for pointer, expected in row["semantic_sha256"].items():
            value = source
            for key in pointer[1:].split("/"):
                value = value[key]
            require(digest(canonical(value)) == expected, f"semantic digest {name}{pointer}")
        sources[row["path"]] = digest(data)
        original += len(pointers)
        additional += len(row["semantic_sha256"]) - len(pointers)
    dimensions = {"authorities": 16, "original_anchors": original, "additional_anchors": additional}
    for section, symbol, fields in (
        ("operations", "OPERATION_REGISTER", ("included", "authorities", "scopes")),
        ("scopes", "SCOPE_REGISTER", ("visible", "restored", "publication", "authorities")),
    ):
        entries = register(read(CHECKER), symbol)
        require(set(entries) == set(current[section]), f"register keys {section}")
        for name, values in entries.items():
            for field, value in zip(fields, values, strict=True):
                expected = value.split() if type(current[section][name][field]) is list else value
                require(expected == current[section][name][field], f"register edge {section}/{name}/{field}")
        dimensions[section] = len(entries)
    require((original, additional, dimensions["operations"], dimensions["scopes"]) == (66, 24, 7, 8), "dimensions")
    check_policy_schema(read(CHECKER))

    # Byte preservation protects every external repair's status AND prerequisites.
    task_paths = git("ls-tree", "-r", "--name-only", POLICY, "docs/tasks").decode().splitlines()
    external, statuses = {}, {}
    for path in task_paths:
        if not path.endswith(".md"):
            continue
        data = read(path)
        if path != "docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md":
            require(data == committed(POLICY, path), f"external task drift {path}")
            external[path] = digest(data)
        for task_id, status in re.findall(r"^- ID: `([^`]+)`\n  Status: `([^`]+)`", data.decode(), re.M):
            require(task_id not in statuses or statuses[task_id] == status, f"ambiguous owner {task_id}")
            statuses[task_id] = status
    owners = set(re.findall(r'"((?:SPEC-LANGUAGE-SELF-CONTAINMENT|SESSION-STARTUP-READING|FUTURE-PARITY-BACKLOG|DART-STARTUP-READING|JULIA-STARTUP-READING|LUA-STARTUP-READING|PARSER-AUTHORING-APIS|LUA-BACKEND-PARITY)\.[0-9.]+)"', canonical(current).decode()))
    for owner in owners:
        require(bool(statuses.get(owner)), f"owner resolution {owner}")
    references = set(current["references"].values()) | {current["obligations"]["finite_ledger"]}
    for path in references:
        require(bool(read(path)), f"reference empty {path}")
    book, html = read(BOOK), read(HTML)
    rendered = rendered_text(html)
    for claim in BOOK_CLAIMS:
        require(claim in " ".join(book.decode().split()), f"book source claim {claim}")
        require(claim in rendered, f"book rendered claim {claim}")
    for claim in POLICY_BOOK_CLAIMS:
        require(claim in rendered, f"policy rendered claim {claim}")
    runtime, runtime_html = read(RUNTIME_BOOK), read(RUNTIME_HTML)
    require(runtime == committed(POLICY, RUNTIME_BOOK), "runtime book drift")
    for claim in RUNTIME_CLAIMS:
        require(claim in rendered_text(runtime_html), f"runtime rendered claim {claim}")
    return {"format": 1, "owner": OWNER, "review_date": "2026-10-02",
            "activation_commit": POLICY, "structure_baseline": STRUCTURE,
            "policy_baseline": POLICY, "scope": "structural evidence; no new runtime execution or admission",
            "dimensions": dimensions, "source_sha256": sources,
            "external_task_sha256": external, "owners_resolved": len(owners),
            "owner_statuses": {owner: statuses[owner] for owner in sorted(owners)},
            "inputs_sha256": {path: digest(read(path)) for path in (CONTRACT, MATRIX, CHECKER)},
            "references_resolved": len(references), "book": {"source_sha256": digest(book),
            "render_sha256": digest(html), "claims": list(BOOK_CLAIMS),
            "preserved_policy_claims": list(POLICY_BOOK_CLAIMS),
            "runtime_source_sha256": digest(runtime), "runtime_render_sha256": digest(runtime_html),
            "runtime_claims": list(RUNTIME_CLAIMS)}}


def expect_rejection(read, reason):
    try:
        audit(read)
    except ValueError as error:
        require(str(error) == reason, f"unrelated rejection: {error}")
    else:
        raise ValueError(f"corruption accepted: {reason}")


def controls():
    cases = (
        (MATRIX, lambda b: b.replace(b"/precedence", b"/validation", 1), "original matrix drift"),
        ("capability_conformance/root_rule_selection_contract.json", lambda b: b + b" ", "authority bytes root_rule_selection"),
        (CONTRACT, lambda b: b.replace(b"no_sandbox_proof", b"sandbox_proven", 1), "policy baseline drift"),
        (CHECKER, lambda b: b.replace(b"9.1.1.2", b"9.1.1.3", 1), "register owner root_rule_selection"),
        (CHECKER, lambda b: b.replace(b"no_sandbox_proof", b"sandbox_proven", 1), "checker policy schema drift"),
        ("docs/tasks/DART-STARTUP-READING.md", lambda b: b + b"\n", "external task drift docs/tasks/DART-STARTUP-READING.md"),
        (BOOK, lambda b: b.replace(BOOK_CLAIMS[0].encode(), b"weakened", 1), "book source claim " + BOOK_CLAIMS[0]),
        (HTML, lambda b: b.replace(BOOK_CLAIMS[1].encode(), b"weakened", 1), "book rendered claim " + BOOK_CLAIMS[1]),
    )
    results = []
    for path, change, reason in cases:
        original = read_relative(path)
        changed = change(original)
        require(changed != original, f"control did not mutate {path}")
        def read(candidate):
            return changed if candidate == path else read_relative(candidate)
        expect_rejection(read, reason)
        results.append({"path": path, "rejection": reason})
    # A different earlier rejection cannot stand in for the selected book control.
    bad = load(read_relative(CONTRACT))
    bad["reconciliation_owner"] = "unrelated"
    try:
        expect_rejection(lambda path: canonical(bad) if path == CONTRACT else read_relative(path),
                         "book source claim " + BOOK_CLAIMS[0])
    except ValueError as error:
        require(str(error) == "unrelated rejection: reconciliation owner", "unrelated-error control failed")
    else:
        raise ValueError("unrelated rejection counted as proof")
    return {"reason_sensitive": results, "unrelated_error_control": "distinct rejection required"}


if __name__ == "__main__":
    result = audit()
    result["controls"] = controls()
    print(json.dumps(result, indent=2, sort_keys=True))
