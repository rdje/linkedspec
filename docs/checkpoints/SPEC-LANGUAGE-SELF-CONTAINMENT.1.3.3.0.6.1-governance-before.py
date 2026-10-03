"""Reconcile historical objective evidence without claiming fresh runtime execution.

Run with tools/run_python_project_data.sh. Current runtime/test inputs must match
the latest audited milestone. Exact owner-bound CI insertions must reconstruct
the historical bytes; documentation remains revision-bound.
"""

import hashlib
import json
from pathlib import Path
import subprocess


ROOT = Path(__file__).resolve().parents[2]
PREFIX = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3."
MILESTONES = ("1.2.3", "2.7", "3.5")
RUNTIMES = ("perl", "rust", "dart", "julia", "puc", "luajit")
GOVERNANCE_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2"
COMPOSED_GOVERNANCE_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2"
PUSH_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1"
NORMALIZATION_CORRECTION_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1"
SIGNATURE_REPAIR_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1"
SIGNATURE_BEFORE = "67af62f7aa6dff39b6c3fd64b15fb5139f691a0a"
SIGNATURE_AFTER = "446fb65fadca2e1bd31fec93bb9de779eb2134d1"
# Only these reviewed CI insertions and Perl inventory replacements may evolve
# historical executable inputs. Normalization must recover every original byte.
CI_INSERTIONS = (
    (b"require_tracked_file tools/check_typed_source_location_contract.py\n",
     b"require_tracked_file tools/check_language_closure_contract.py\n"
     b"require_tracked_file capability_conformance/language_closure_contract.json\n"),
    (b"perl tools/check_capability_conformance.pl\n\n",
     b'log "checking language closure operation/scope/reference structure"\n'
     b"bash tools/run_python_project_data.sh tools/check_language_closure_contract.py\n\n"),
)
COMPOSED_CI_INSERTIONS = (
    (b"require_tracked_file capability_conformance/language_closure_contract.json\n",
     b"require_tracked_file tools/check_composed_objective_contract.py\n"
     b"require_tracked_file capability_conformance/composed_objective_contract.json\n"
     b"require_tracked_file tests/language-readiness/composed/diagnostic.spec\n"
     b"require_tracked_file tests/language-readiness/composed/normalization.spec\n"
     b"require_tracked_file tests/language-readiness/composed/diagnostic-invalid-arity.spec\n"),
    (b"bash tools/run_python_project_data.sh tools/check_language_closure_contract.py\n\n",
     b'log "checking neutral composed objective fixtures and independent observations"\n'
     b"bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py\n\n"),
)
PUSH_CI_INSERTIONS = (
    (b"require_tracked_file t/phase0_regression.t\n",
     b"require_tracked_file t/codeblock_push_composition_perl.t\n"),
    (b"PERL5LIB= prove -Iperl t/callable_codeblock_literal_contract.t\n",
     b'\nlog "running Perl deferred push composition and caller-identity fixture"\n'
     b"PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t\n"),
)
NORMALIZATION_CI_INSERTIONS = (
    (b"require_tracked_file tests/language-readiness/composed/normalization.spec\n",
     b"require_tracked_file tests/language-readiness/composed/normalization-calls.spec\n"
     b"require_tracked_file t/composed_normalization_perl.t\n"
     b"require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl\n"),
    (b"PERL5LIB= prove -Iperl t/codeblock_push_composition_perl.t\n",
     b'\nlog "running Perl call-form normalization source and native/fresh object controls"\n'
     b"PERL5LIB= prove -Iperl t/composed_normalization_perl.t\n"),
)
ARTIFACT_RECOVERY_OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1"
ARTIFACT_CI_INSERTIONS = (
    (b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-fresh.pl\n',
     b'require_tracked_file tests/language-readiness/recover_objective_audit_inputs.py\n'
     b'require_tracked_file tests/language-readiness/artifacts/objective-audit-inputs.zip\n'
     b'require_tracked_file tests/language-readiness/artifacts/objective-audit-inputs.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-census.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0-verification.json\n'
     b'require_tracked_file tests/language-readiness/verify_objectives.py\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-verification.json\n'
     b'require_tracked_file docs/language-readiness/objective-reconciliation.md\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3-verification.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7-verification.json\n'
     b'require_tracked_file docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json\n'
    ),
    (b'bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py\n\n',
     b'log "checking isolated historical artifact recovery and read-denied audit"\n'
     b'bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py\n'
     b'\n'
    ),
)

PERL_STORAGE_REPLACEMENTS = (
    (b"(( ${#perl_temp_owners[@]} == 27 )) ||\n",
     b"(( ${#perl_temp_owners[@]} == 28 )) ||\n"),
    (b' fail "tracked Perl temporary-allocation inventory drifted from 27 to ${#perl_temp_owners[@]}"\n',
     b' fail "tracked Perl temporary-allocation inventory drifted from 28 to ${#perl_temp_owners[@]}"\n'),
    (b"for owner in t/legacy_pathsearch_fallback.t t/nested_tree_readiness.t t/lua_legacy_temp_residue.t; do\n",
     b"for owner in t/legacy_pathsearch_fallback.t t/nested_tree_readiness.t t/lua_legacy_temp_residue.t t/codeblock_push_composition_perl.t; do\n"),
    (b" '[perl-project-data-test] PASS: 27 Perl allocators, traces, and CLI workspaces stay on repository storage'\n",
     b" '[perl-project-data-test] PASS: 28 Perl allocators, traces, and CLI workspaces stay on repository storage'\n"),
)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def read_relative(path):
    candidate = Path(path)
    require(not candidate.is_absolute() and ".." not in candidate.parts,
            f"non-repository evidence path: {path}")
    resolved = (ROOT / candidate).resolve()
    resolved.relative_to(ROOT)
    return resolved.read_bytes()


def producing_commit(path):
    commit = git("log", "--diff-filter=A", "-1", "--format=%H", "--", path).decode().strip()
    require(len(commit) == 40, f"missing producing commit: {path}")
    return commit


def verify_governance_evolution(source, contents, historical_hash):
    require(source == "tools/run_ci_local.sh", f"unapproved governance source: {source}")
    normalized = contents
    # Strip the later insertions first: their anchors are earlier owned additions.
    for anchor, insertion in (ARTIFACT_CI_INSERTIONS + NORMALIZATION_CI_INSERTIONS + PUSH_CI_INSERTIONS
                              + COMPOSED_CI_INSERTIONS + CI_INSERTIONS):
        require(normalized.count(anchor + insertion) == 1,
                f"governance registration mismatch: {source}")
        normalized = normalized.replace(anchor + insertion, anchor, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed governance drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": GOVERNANCE_OWNER,
            "additional_owner": COMPOSED_GOVERNANCE_OWNER,
            "runtime_repair_owner": PUSH_REPAIR_OWNER,
            "source_correction_owner": NORMALIZATION_CORRECTION_OWNER,
            "artifact_recovery_owner": ARTIFACT_RECOVERY_OWNER,
            "scope": "exact anchored checker/input registration; original CI bytes preserved"}


def signature_subtest(contents):
    start = b"subtest 'actionir_statement_split_core_requires_newline_or_semicolon_boundaries' => sub {\n"
    following = b"subtest 'actionir_canonical_events_require_avoids_core_load_until_build' => sub {\n"
    require(contents.count(start) == contents.count(following) == 1,
            "signature regression marker mismatch: t/phase0_regression.t")
    first = contents.index(start)
    end = contents.index(following, first)
    return contents[first:end]


def verify_signature_regression_evolution(source, contents, historical_hash):
    require(source == "t/phase0_regression.t", f"unapproved signature regression source: {source}")
    before = git("show", f"{SIGNATURE_BEFORE}:{source}")
    after = git("show", f"{SIGNATURE_AFTER}:{source}")
    require(contents == after, f"unreviewed signature-regression drift: {source}")
    # Replace only the exact owned subtest, including its fixed/dynamic plan change.
    normalized = contents.replace(signature_subtest(after), signature_subtest(before), 1)
    require(normalized == before and digest(normalized) == historical_hash,
            f"unreviewed signature-regression history: {source}")
    return {"path": source, "historical": historical_hash, "current": digest(contents),
            "owner": SIGNATURE_REPAIR_OWNER, "reconciliation_owner": NORMALIZATION_CORRECTION_OWNER,
            "before_revision": SIGNATURE_BEFORE, "after_revision": SIGNATURE_AFTER,
            "scope": "exact committed signature subtest and plan replacement only; original Phase0 bytes recovered"}


def verify_perl_storage_evolution(source, contents, historical_hash):
    require(source == "tools/test_perl_project_data_storage.sh",
            f"unapproved Perl storage source: {source}")
    normalized = contents
    for historical, current in PERL_STORAGE_REPLACEMENTS:
        require(normalized.count(current) == 1,
                f"Perl storage registration mismatch: {source}")
        normalized = normalized.replace(current, historical, 1)
    require(digest(normalized) == historical_hash,
            f"unreviewed Perl storage drift: {source}")
    return {"path": source, "historical": historical_hash,
            "current": digest(contents), "owner": PUSH_REPAIR_OWNER,
            "scope": "exact 27-to-28 census and new allocator membership; original bytes preserved"}


def audit_evidence(read=read_relative):
    checkpoints, sources, logs, milestones = {}, {}, {}, {}
    references = 0

    def checkpoint(path, expected=None):
        contents = read(path)
        if expected is not None:
            require(digest(contents) == expected, f"checkpoint digest mismatch: {path}")
        commit = producing_commit(path)
        require(git("show", f"{commit}:{path}") == contents,
                f"checkpoint changed since production: {path}")
        record = json.loads(contents)
        require(record["owner"] + "-verification.json" == Path(path).name,
                f"checkpoint owner mismatch: {path}")
        checkpoints[path] = {"sha256": digest(contents), "producing_commit": commit}
        return record, commit

    for suffix in MILESTONES:
        path = f"docs/checkpoints/{PREFIX}{suffix}-verification.json"
        record, milestone_commit = checkpoint(path)
        milestones[suffix] = record
        if "audit" in record:
            audit = record["audit"]
            children = [(p, row["sha256"]) for p, row in audit["checkpoints"].items()]
            comparisons = []
            for child_path, expected in children:
                child, child_commit = checkpoint(child_path, expected)
                for source, source_hash in child["source_hashes"].items():
                    comparisons.append((source, source_hash, child_commit))
            current_hashes = audit["current_source_hashes"]
            log_hashes = audit["log_hashes"]
        else:
            for row in record["checkpoint_hashes"]:
                checkpoint(row["path"], row["sha256"])
            comparisons = [(row["path"], row["recorded"],
                            checkpoints[row["checkpoint"]]["producing_commit"])
                           for row in record["source_hash_comparisons"]]
            current_hashes = {row["path"]: row["current"]
                              for row in record["source_hash_comparisons"]}
            log_hashes = {row["path"]: row.get("sha256", row.get("recorded"))
                          for row in record["log_hashes"]}
        for source, expected, commit in comparisons:
            require(digest(git("show", f"{commit}:{source}")) == expected,
                    f"historical source mismatch: {source} at {commit}")
            references += 1
        for source, expected in current_hashes.items():
            require(digest(git("show", f"{milestone_commit}:{source}")) == expected,
                    f"milestone source mismatch: {source}")
            sources[source] = {"sha256": expected, "milestone": suffix}
        for log, expected in log_hashes.items():
            require(digest(read(log)) == expected, f"retained log mismatch: {log}")
            if log in logs:
                require(logs[log] == expected, f"conflicting log digest: {log}")
            logs[log] = expected

    documentation_updates, governance_updates = [], []
    for source, row in sources.items():
        current = digest(read(source))
        if current != row["sha256"]:
            if source == "tools/run_ci_local.sh":
                governance_updates.append(verify_governance_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "tools/test_perl_project_data_storage.sh":
                governance_updates.append(verify_perl_storage_evolution(
                    source, read(source), row["sha256"]))
                continue
            if source == "t/phase0_regression.t":
                governance_updates.append(verify_signature_regression_evolution(
                    source, read(source), row["sha256"]))
                continue
            require(source.startswith("docs/") and source.endswith(".md"),
                    f"current executable evidence drift: {source}")
            documentation_updates.append({"path": source, "historical": row["sha256"],
                                          "current": current, "milestone": row["milestone"]})

    # Read the original independent oracle, rather than deriving expected case
    # counts or coordinates from a runtime checker or this summary's prose.
    corpora = {}
    for stem in ("nested-tree", "context-names", "lossless-segments", "lossless-child"):
        path = f"tests/language-readiness/{stem}/cases.json"
        cases = json.loads(read(path))
        accepts, rejects = cases["accept"], cases.get("reject", [])
        names = [row if isinstance(row, str) else row.get("id", row["input"])
                 for row in accepts + rejects]
        require(len(names) == len(set(names)), f"duplicate authored case: {stem}")
        spans = 0

        def walk(value, text):
            nonlocal spans
            if isinstance(value, list):
                for child in value:
                    walk(child, text)
            elif isinstance(value, dict):
                if "span" in value:
                    span = value["span"]
                    first, last = span if isinstance(span, list) else (span["start"], span["end"])
                    require(type(first) is int and type(last) is int and
                            0 <= first <= last <= len(text), f"invalid scalar span: {stem}")
                    if "text" in value:
                        require(text[first:last] == value["text"], f"wrong scalar slice: {stem}")
                    spans += 1
                for key, child in value.items():
                    if key != "span":
                        walk(child, text)

        for case in accepts:
            walk(case["expected"], case["input"])
            if stem == "lossless-segments":
                cursor = 0
                for segment in case["expected"]:
                    span = segment["span"]
                    first, last = span if isinstance(span, list) else (span["start"], span["end"])
                    require(first == cursor, "lossless segments are not adjacent")
                    cursor = last
                require(cursor == len(case["input"]), "lossless segments omit input")
        corpora[stem] = {"accept": len(accepts), "reject": len(rejects),
                         "authored_spans": spans, "case_names": names,
                         "sha256": digest(read(path))}

    matrices = {}
    for suffix, key in (("1.2.3", "routes"), ("2.7", "typed_routes"), ("3.5", "carrier_pairs")):
        rows = {("puc" if name == "puc_lua" else name): row
                for name, row in milestones[suffix][key].items()}
        require(set(rows) == set(RUNTIMES), f"runtime membership mismatch: {suffix}")
        for row in rows.values():
            routes = row.get("routes", row.get("matched"))
            require(0 < row["retained"] <= routes, f"invalid retained routes: {suffix}")
            if suffix != "3.5":
                rejected = corpora["nested-tree" if suffix == "1.2.3" else "context-names"]["reject"]
                require(row["recoveries"] == row["retained"] * 2 * rejected,
                        f"recovery inflation: {suffix}")
            else:
                require(row["per_call"] == routes - row["retained"], "per-call pair mismatch")
        matrices[suffix] = rows

    return {"checkpoints": checkpoints, "historical_source_references": references,
            "latest_source_inputs": sources, "retained_log_hashes": logs,
            "documentation_updates": documentation_updates,
            "governance_updates": governance_updates, "corpora": corpora,
            "matrices": matrices,
            "limits": "Evidence integrity and independent scalar slicing; runtime execution is historical per-leaf proof. No new capability or objective promotion."}


def falsify(report):
    targets = (next(iter(report["checkpoints"])), next(iter(report["latest_source_inputs"])),
               next(iter(report["retained_log_hashes"])),
               "tests/language-readiness/context-names/cases.json")
    for target in targets:
        def corrupt(path):
            data = read_relative(path)
            return data + b" " if path == target else data
        try:
            audit_evidence(corrupt)
        except ValueError:
            continue
        raise ValueError(f"corruption control did not reject: {target}")
    for target in ("../outside", "/outside"):
        try:
            read_relative(target)
        except ValueError:
            continue
        raise ValueError(f"outside-path control did not reject: {target}")
    governance_controls = 0
    controls_by_source = {}
    for row in report["governance_updates"]:
        source = row["path"]
        current = read_relative(source)
        if source == "tools/run_ci_local.sh":
            altered = (
                current + b"# unreviewed edit\n",
                current.replace(CI_INSERTIONS[0][1], b"", 1),
                current.replace(b"bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py\n", b"", 1),
                current.replace(b"require_tracked_file capability_conformance/composed_objective_contract.json\n",
                                b"", 1),
                current.replace(COMPOSED_CI_INSERTIONS[1][1], b"", 1),
                current.replace(COMPOSED_CI_INSERTIONS[1][1],
                                COMPOSED_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(PUSH_CI_INSERTIONS[0][1], b"", 1),
                current.replace(PUSH_CI_INSERTIONS[1][1], b"", 1),
                current.replace(PUSH_CI_INSERTIONS[1][1], PUSH_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[0][1], b"", 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[1][1], b"", 1),
                current.replace(NORMALIZATION_CI_INSERTIONS[1][1],
                                NORMALIZATION_CI_INSERTIONS[1][1] * 2, 1),
                current.replace(ARTIFACT_CI_INSERTIONS[0][1], b"", 1),
                current.replace(ARTIFACT_CI_INSERTIONS[1][1], b"", 1),
                current.replace(ARTIFACT_CI_INSERTIONS[1][1],
                                ARTIFACT_CI_INSERTIONS[1][1] * 2, 1),
            )
            verify = verify_governance_evolution
            reasons = ("governance registration mismatch:", "unreviewed governance drift:")
        elif source == "tools/test_perl_project_data_storage.sh":
            altered = (current + b"# unreviewed edit\n",) + tuple(
                current.replace(replacement, historical, 1)
                for historical, replacement in PERL_STORAGE_REPLACEMENTS
            ) + (current.replace(PERL_STORAGE_REPLACEMENTS[2][1],
                                 PERL_STORAGE_REPLACEMENTS[2][1] * 2, 1),)
            verify = verify_perl_storage_evolution
            reasons = ("Perl storage registration mismatch:", "unreviewed Perl storage drift:")
        elif source == "t/phase0_regression.t":
            before = git("show", f"{SIGNATURE_BEFORE}:{source}")
            owned = signature_subtest(current)
            altered = (
                current.replace(owned, signature_subtest(before), 1),
                current.replace(owned, owned.replace(b"    done_testing();\n",
                                                    b"    plan tests => 8;\n", 1), 1),
                current + b"# unreviewed edit outside the owned subtest\n",
            )
            verify = verify_signature_regression_evolution
            reasons = ("unreviewed signature-regression drift:",
                       "unreviewed signature-regression history:", "signature regression marker mismatch:")
        else:
            raise ValueError(f"unapproved governance control source: {source}")
        require(all(candidate != current for candidate in altered),
                f"governance controls must change actual bytes: {source}")
        controls_by_source[source] = 0
        for contents in altered:
            try:
                verify(source, contents, row["historical"])
            except ValueError as error:
                require(str(error).startswith(reasons),
                        "unrelated error substituted for governance rejection")
                governance_controls += 1
                controls_by_source[source] += 1
            else:
                raise ValueError("governance corruption control did not reject")
    return {"corrupted_inputs_rejected": list(targets), "outside_paths_rejected": 2,
            "governance_mutations_rejected": governance_controls,
            "governance_mutations_by_source": controls_by_source}


def verify_summary(report, text):
    labels = dict(zip(RUNTIMES, ("Perl", "Rust", "Dart", "Julia", "PUC Lua", "LuaJIT")))
    for runtime in RUNTIMES:
        nesting = report["matrices"]["1.2.3"][runtime]
        context = report["matrices"]["2.7"][runtime]
        child = report["matrices"]["3.5"][runtime]
        require(nesting["routes"] == context["routes"] and
                nesting["retained"] == context["retained"], "combined route table loses a distinction")
        row = (f"| {labels[runtime]} | {nesting['routes']} | {nesting['retained']} | "
               f"{nesting['recoveries']} / {context['recoveries']} | {child['matched']} | "
               f"{child['retained']} | {child['per_call']} |")
        require(text.splitlines().count(row) == 1, f"summary route mismatch: {runtime}")


if __name__ == "__main__":
    result = audit_evidence()
    result["controls"] = falsify(result)
    summary = read_relative("docs/language-readiness/objective-reconciliation.md").decode()
    verify_summary(result, summary)
    try:
        verify_summary(result, summary.replace("| 28 / 68 |", "| 29 / 68 |", 1))
    except ValueError:
        result["controls"]["summary_recovery_inflation_rejected"] = True
    else:
        raise ValueError("summary recovery inflation control did not reject")
    print(json.dumps(result, indent=2, sort_keys=True))
