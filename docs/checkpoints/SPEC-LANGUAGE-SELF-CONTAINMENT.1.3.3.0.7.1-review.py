"""Read-only source-bound review of readiness repair and retained observations."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "c9673d7eff39836fdc94d59b8d47639db5e937d4"
SPAN_SPEC = importlib.util.spec_from_file_location("raw_readiness_span_oracle", ROOT / (PREFIX + "span-normalize.py"))
SPAN = importlib.util.module_from_spec(SPAN_SPEC)
SPAN_SPEC.loader.exec_module(SPAN)
NEW_FIELDS = {"raw_perl_expression_dependencies", "raw_perl_expression_source_units"}
CHANGED_FIELDS = NEW_FIELDS | {"raw_perl_dependency_count", "raw_perl_dependency_statements",
    "language_agnostic_action_ir_ready", "language_agnostic_action_ir_blocker_statements",
    "language_agnostic_action_ir_blocker_statement_count"}
RAW = {name: ["i+1"] for name in (
    "assignment_raw", "call_argument_raw", "array_element_raw", "hash_value_raw",
    "codeblock_body_raw", "action_edge_raw", "blind_edge_raw", "and_local_raw",
    "lifecycle_e_raw", "lifecycle_ex_raw", "lifecycle_it_raw", "lifecycle_ls_raw",
    "lifecycle_le_raw", "lifecycle_lx_raw")}
RAW.update({"condition_raw": ["i < 1"], "while_raw": ["i < 1"],
            "repeated_raw": ["i+1", "i+1"], "repeated_units": ["i+1", "i+1"],
            "raw_statement": ["$host"]})
KINDS = {"action_edge_raw": "acode", "blind_edge_raw": "bcode", "and_local_raw": "and_icode"}
KINDS.update({"lifecycle_" + name + "_raw": name + "code"
              for name in ("e", "ex", "it", "ls", "le", "lx")})
TESTS = {"t/actionir_raw_dependency_metadata.t": 16,
         "t/actionir_raw_dependency_provenance.t": 6,
         "t/canonical_event_occurrence_order.t": 15, "t/trace_actionir_pipeline.t": 5,
         "t/noncurrent_helper_metadata.t": 2, "t/actionir_ast_parser.t": 23,
         "t/trace_actionir_method_lowering.t": 4, "t/generated_source_contract.t": 12,
         "t/codeblock_while_perl.t": 33, "t/recursive_observation_perl_contract.t": 7,
         "t/recognition_transaction_perl_contract.t": 51,
         "t/progressive_span_dispatch_perl_contract.t": 129,
         "t/staged_ast_enrichment_perl_contract.t": 143}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read(path):
    require(not Path(path).is_absolute() and ".." not in Path(path).parts, "relative input")
    candidate = (ROOT / path).resolve()
    candidate.relative_to(ROOT)
    return candidate.read_bytes()


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def raw_markers(value):
    if isinstance(value, dict):
        return int(value.get("kind") == "raw_perl") + sum(raw_markers(x) for x in value.values())
    if isinstance(value, list):
        return sum(raw_markers(x) for x in value)
    return 0


def frozen(meta, fields=CHANGED_FIELDS):
    return {key: value for key, value in meta.items() if key not in fields}


def census(record, cases):
    require(record["owner"] == OWNER and record["seed"] == "0", "census population")
    found = {}
    shipped = set(subprocess.check_output(["git", "ls-files", "specs/*.spec"],
                                        cwd=ROOT, text=True).splitlines())
    for row in record["rows"]:
        x = row["observation"]
        key = x["id"]
        require(key not in found and row["exit"] == 0 and row["stderr"] == "" and
                json.loads(row["stdout"]) == x, "census actual producer")
        require(x["descriptor_kind"] == "HASH" and x["input_route"] == "Get_source_ref"
                and x["exception"] is None and x["context_error"] is None,
                "census descriptor route")
        require(x["source"] == row["request"]["source"] and
                sha(x["source"].encode()) == row["source_sha256"], "census source identity")
        if key.startswith("control:"):
            require(x["source"] == cases[key[8:]]["source"], "control census source")
        else:
            require(key.startswith("shipped:") and key[8:] in shipped and
                    read(key[8:]) == x["source"].encode(), "shipped census byte identity")
        require(all(unit["ast_error"] is None for unit in x["units"]), "census action AST")
        found[key] = x
    require(set(found) == {"control:" + name for name in cases} |
            {"shipped:" + path for path in shipped}, "complete census population")
    require(len(shipped) == 22 and len(found) == 55, "frozen census size")
    return found


def oracle(name, before):
    wanted = RAW.get(name, [])
    units, dependencies, observed = [], [], []
    for unit in before["control:" + name]["units"]:
        if unit["label"] != "Top":
            continue
        source = unit["source"]
        if name == "blind_edge_raw" and "i+1" in source:
            require(source == "$Top = call(Done);\n return(i+1) ", "blind source before bridge")
            source = " return(i+1) "
        matches = []
        for token in set(wanted):
            # The explicit legacy control owns its declaration through RAW_PERL;
            # only the later return's host read is an uncovered expression.
            pattern = r"(?<=return\()\$host" if name == "raw_statement" else re.escape(token)
            matches.extend((match.start(), match.end(), token)
                           for match in re.finditer(pattern, source))
        if not matches:
            continue
        index = len(units)
        item = {"kind": KINDS.get(name, "icode"), "index": index, "source": source}
        if name == "blind_edge_raw":
            item["target"] = "Done"
        units.append(item)
        for start, end, token in sorted(matches):
            observed.append(token)
            dependencies.append({"source": token, "reason": "unsupported_expression",
                                 "source_span": {"start": start, "end": end},
                                 "source_unit": index})
    require(observed == wanted, "independent source occurrence oracle")
    return units, dependencies


def metadata(name, prior, current, units, dependencies):
    require(set(current) == set(prior) | NEW_FIELDS and frozen(current) == frozen(prior),
            "unchanged metadata contracts")
    require(current["raw_perl_expression_source_units"] == units, "source unit provenance")
    require(current["raw_perl_expression_dependencies"] == dependencies, "source occurrence provenance")
    display = list(prior["raw_perl_dependency_statements"])
    for dependency in dependencies:
        if dependency["source"] not in display:
            display.append(dependency["source"])
    require(current["raw_perl_dependency_statements"] == display, "visible raw dependency display")
    require(current["raw_perl_dependency_count"] ==
            prior["canonical_action_ir_fallback_count"] + len(dependencies), "raw occurrence count")
    blockers = list(prior["language_agnostic_action_ir_blocker_statements"])
    for raw in display:
        if raw not in blockers:
            blockers.append(raw)
    require(current["language_agnostic_action_ir_blocker_statements"] == blockers and
            current["language_agnostic_action_ir_blocker_statement_count"] == len(blockers),
            "visible portability blockers")
    require(current["language_agnostic_action_ir_ready"] ==
            (0 if dependencies else prior["language_agnostic_action_ir_ready"]), "repaired readiness")


def observations(record, mode, cases):
    require(record["owner"] == OWNER and record["mode"] == mode and
            record["seeds"] == ["0", "1", "2"] and record["perturbation"] == "2",
            "public capture population")
    found = {}
    for row in record["rows"]:
        require(row["exit"] == 0 and row["stderr"] == "" and
                json.loads(row["stdout"]) == row["observation"] and
                len(row["observation"]["cases"]) == 1, "public actual producer")
        x = row["observation"]["cases"][0]
        name, seed = x["id"], x["seed"]
        require(name in cases and seed in record["seeds"] and (name, seed) not in found,
                "public case seed membership")
        require(row["command"] == ["perl", "-Iperl", PREFIX + "probe.pl", name] and
                x["source"] == cases[name]["source"] and
                x["source_sha256"] == sha(x["source"].encode()), "public source identity")
        require(x["emitted_sha256"] == x["fresh"]["emitted_sha256"] == sha(x["emitted"].encode()),
                "independent fresh emitted identity")
        require(x["substitution_sha256"] ==
                (sha(x["substitution"].encode()) if x["substitution"] is not None else None),
                "substitution identity")
        if name == "codeblock_body_raw":
            native, fresh = x["native"]["context_error"], x["fresh"]["exception"]
            require(native["type"] == "runtime_handler" and fresh["type"] == "generated_source_error"
                    and native["detail"] == fresh["detail"] and
                    native["detail"]["code"] == "unsupported_codeblock_actionir" and
                    native["detail"]["kind"] == "raw_perl" and
                    x["native"]["actual_error_identity"] == x["fresh"]["actual_error_identity"] == 1,
                    "retained deferred failure identity")
            lines = x["native"]["stdout"].splitlines()
            prefix = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]\[NONE\]\[SpecEntry\.pm\]\[trace_decision:63\] "
            require(len(lines) == 2 and re.fullmatch(prefix + r"DECISION rule_handler_eval:Top => SKIPPED", lines[0])
                    and re.fullmatch(prefix + r"  Context: bless\( \{'code' => 'unsupported_codeblock_actionir','kind' => 'raw_perl'\}, 'LinkedSpec::CodeblockRuntime::Error' \)", lines[1]),
                    "retained native failure trace")
        else:
            require(x["native"]["exception"] is None and x["native"]["context_error"] is None
                    and x["fresh"]["exception"] is None and x["native"]["stdout"] == "",
                    "retained healthy error channels")
        require(x["fresh"]["stdout"] == "", "quiet fresh route")
        found[(name, seed)] = x
    require(set(found) == {(name, seed) for name in cases for seed in record["seeds"]},
            "complete public capture")
    return found


def comparison(before, after, cases, baseline_census):
    results = []
    for name in cases:
        units, deps = oracle(name, baseline_census)
        for seed in ("0", "1", "2"):
            old, new = before[(name, seed)], after[(name, seed)]
            require(new["ast"] == SPAN.ast(old["ast"]), "bounded compiler AST coordinate repair")
            for field in ("action_probe_source", "substitution", "dump", "emitted"):
                require(SPAN.source_equal(old[field], new[field]), "unchanged compiler output: " + field)
            metadata(name, old["metadata"], new["metadata"], units, deps)
            for route in ("native", "fresh"):
                for field in ("value", "exception", "context_error", "invocations", "actual_error_identity"):
                    if field in old[route]:
                        require(new[route][field] == old[route][field], "unchanged consumer observation: " + field)
            if name in ("assignment_raw", "condition_raw", "while_raw", "call_argument_raw",
                        "array_element_raw", "hash_value_raw"):
                for x in (old, new):
                    require('Unquoted string "i"' in x["fresh"]["stderr"] and
                            'Argument "i" isn\'t numeric' in x["fresh"]["stderr"],
                            "retained host warnings")
        for seed in ("1", "2"):
            for field in ("ast", "metadata", "substitution", "dump", "emitted"):
                require(after[(name, seed)][field] == after[(name, "0")][field],
                        "current measured seed stability")
        x = after[(name, "0")]
        results.append({"id": name, "raw_occurrences": len(deps),
                        "raw_count": x["metadata"]["raw_perl_dependency_count"],
                        "ready": x["metadata"]["language_agnostic_action_ir_ready"],
                        "source_units": units, "native_value": x["native"]["value"]})
    return results


def compare_census(before, after, cases):
    unit_count = 0
    for key, old in before.items():
        new = after[key]
        require(new["source"] == old["source"] and new["functions"] == old["functions"]
                and len(new["units"]) == len(old["units"]), "unchanged census population/functions")
        for a, b in zip(old["units"], new["units"]):
            require(set(a) == set(b), "unchanged census unit schema")
            for field in set(a) - {"diagnostics"}:
                require((SPAN.ast(a[field]) == b[field]) if field == "ast" else
                        SPAN.source_equal(a[field], b[field]), "unchanged census AST/lowering")
            require(frozen(a["diagnostics"], NEW_FIELDS) == frozen(b["diagnostics"], NEW_FIELDS),
                    "unchanged per-unit event diagnostics")
            unit_count += 1
        require(set(old["metadata"]) == set(new["metadata"]), "unchanged census rule labels")
        for label, meta in old["metadata"].items():
            if key.startswith("control:") and label == "Top":
                units, deps = oracle(key[8:], before)
            else:
                units, deps = [], []
            metadata(key, meta, new["metadata"][label], units, deps)
    return unit_count


def tests(record):
    found = {}
    for row in record["rows"]:
        name = row["command"][-1]
        require(name in TESTS and name not in found and row["exit"] == 0, "TAP exit/membership")
        require(re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M) == [str(TESTS[name])]
                and "Result: PASS" in row["stdout"] and
                re.search(r"Files=1, Tests=" + str(TESTS[name]) + r"\b", row["stdout"]),
                "complete TAP plan/result")
        found[name] = TESTS[name]
    require(found == TESTS, "complete direct test selection")
    return found


def reject(name, action, reason):
    try:
        action()
    except ValueError as error:
        require(str(error) == reason, "unrelated corruption rejection: " + name + ": " + str(error))
        return {"name": name, "reason": str(error)}
    raise ValueError("corruption accepted: " + name)


def main():
    cases = {row["id"]: row for row in json.loads(read(PREFIX + "cases.json"))}
    require(len(cases) == 33, "frozen full source population")
    b = census(json.loads(read(PREFIX + "census-before.json")), cases)
    a = census(json.loads(read(PREFIX + "census-after.json")), cases)
    old_record, new_record = (json.loads(read(PREFIX + name + ".json")) for name in ("before", "after"))
    old, new = observations(old_record, "before", cases), observations(new_record, "after", cases)
    results = comparison(old, new, cases, b)
    units_count = compare_census(b, a, cases)
    marker_counts = {}
    for mode, population in (("before", b), ("after", a)):
        shipped = sum(raw_markers(unit["ast"]) for key, x in population.items()
                      if key.startswith("shipped:") for unit in x["units"])
        control = sum(raw_markers(unit["ast"]) for key, x in population.items()
                      if key.startswith("control:") for unit in x["units"])
        require(shipped == 0 and control == 27, "bounded raw AST census")
        marker_counts[mode] = {"shipped": shipped, "controls": control}
    historical_prefix = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0-"
    historical_cases = json.loads(read(historical_prefix + "cases.json"))
    require(list(cases.values())[:16] == historical_cases, "exact original source controls")
    historical = json.loads(read(historical_prefix + "observations.json"))
    for row in historical["rows"]:
        x = row["observation"]["cases"][0]
        baseline = old[(x["id"], x["seed"])]
        require(all(baseline[field] == x[field] for field in
                    ("source", "ast", "metadata", "substitution", "dump", "emitted")),
                "historical diagnosis baseline identity")
    test_record = json.loads(read(PREFIX + "tests-after.json"))
    counts = tests(test_record)
    reds = []
    for suffix, plan, failures in (("tests-before", 16, 9), ("tests-provenance-before", 6, 6)):
        record = json.loads(read(PREFIX + suffix + ".json"))
        require(record["mode"] == "before" and len(record["rows"]) == 1, "actual RED population")
        row = record["rows"][0]
        require(row["exit"] == failures and re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M) == [str(plan)]
                and len(re.findall(r"^not ok \d+", row["stdout"], re.M)) == failures,
                "actual RED plan/failure count")
        reds.append({"source": row["command"][-1], "plan": plan, "failed_top_level": failures})
    controls = []
    mutations = (
        ("ready hidden", "assignment_raw", lambda x:x["metadata"].update(language_agnostic_action_ir_ready=1), "repaired readiness"),
        ("raw count hidden", "assignment_raw", lambda x:x["metadata"].update(raw_perl_dependency_count=0), "raw occurrence count"),
        ("source span shifted", "assignment_raw", lambda x:x["metadata"]["raw_perl_expression_dependencies"][0]["source_span"].update(start=0), "source occurrence provenance"),
        ("repeat collapsed", "repeated_raw", lambda x:x["metadata"]["raw_perl_expression_dependencies"].pop(), "source occurrence provenance"),
        ("unit conflated", "repeated_units", lambda x:x["metadata"]["raw_perl_expression_dependencies"][1].update(source_unit=0), "source occurrence provenance"),
        ("blind bridge included", "blind_edge_raw", lambda x:x["metadata"]["raw_perl_expression_source_units"][0].update(source="$Top = call(Done);\n return(i+1) "), "source unit provenance"),
        ("raw display hidden", "assignment_raw", lambda x:x["metadata"].update(raw_perl_dependency_statements=[]), "visible raw dependency display"),
        ("events changed", "assignment_raw", lambda x:x["metadata"]["canonical_action_ir_events"].pop(), "unchanged metadata contracts"),
        ("lowering changed", "assignment_raw", lambda x:x.update(substitution="changed"), "unchanged compiler output: substitution"),
        ("canonical value changed", "assignment_canonical", lambda x:x["fresh"].update(value=4), "unchanged consumer observation: value"),
        ("host warnings lost", "assignment_raw", lambda x:x["fresh"].update(stderr=""), "retained host warnings"),
    )
    for name, target, mutate, reason in mutations:
        altered = copy.deepcopy(new)
        mutate(altered[(target, "0")])
        controls.append(reject(name, lambda: comparison(old, altered, cases, b), reason))
    altered = copy.deepcopy(test_record)
    altered["rows"][0]["exit"] = 1
    controls.append(reject("failed TAP hidden", lambda: tests(altered), "TAP exit/membership"))
    for name, target, mutate, reason in (
        ("source replaced", "assignment_raw", lambda x:x.update(source="Top:: I { return(9) }"), "public source identity"),
        ("fresh source digest replaced", "assignment_raw", lambda x:x["fresh"].update(emitted_sha256="0" * 64), "independent fresh emitted identity"),
        ("original deferred error replaced", "codeblock_body_raw", lambda x:x["fresh"].update(actual_error_identity=0), "retained deferred failure identity"),
        ("native failure trace lost", "codeblock_body_raw", lambda x:x["native"].update(stdout=""), "retained native failure trace"),
    ):
        altered = copy.deepcopy(new_record)
        row = next(row for row in altered["rows"] if row["observation"]["cases"][0]["id"] == target)
        mutate(row["observation"]["cases"][0])
        row["stdout"] = json.dumps(row["observation"])
        controls.append(reject(name, lambda: observations(altered, "after", cases), reason))
    spec = importlib.util.spec_from_file_location("raw_readiness_canonical_failure",
                                                 ROOT / (PREFIX + "canonical-failure.py"))
    failure_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(failure_module)
    failure = json.loads(read(PREFIX + "canonical-before.json"))
    failure_raw = failure_module.validate(failure)
    for field, value, reason in (
        ("base64", "!", "canonical failure base64"),
        ("sha256", "0" * 64, "canonical failure byte identity"),
        ("bytes", len(failure_raw) + 1, "canonical failure byte identity"),
    ):
        altered = copy.deepcopy(failure)
        altered["log_envelope"][field] = value
        controls.append(reject("failed canonical envelope " + field,
                               lambda: failure_module.validate(altered), reason))
    # Execute the independent supplemental reviewer and compare its complete result.
    keyword_run = subprocess.run(["bash", "tools/run_python_project_data.sh", PREFIX + "keyword-review.py"],
                                 cwd=ROOT, capture_output=True, text=True)
    require(keyword_run.returncode == 0 and keyword_run.stderr == "", "keyword supplemental review exit")
    keyword = json.loads(read(PREFIX + "keyword-verification.json"))
    require(json.loads(keyword_run.stdout) == keyword and keyword["result"] == "PASS",
            "keyword supplemental review identity")
    for path, expected in keyword["tracked_inputs"].items():
        require(sha(read(path)) == expected, "keyword supplemental input identity: " + path)
    counts["t/codeblock_push_composition_perl.t"] = keyword["top_level_TAP_tests"]
    controls.extend(keyword["controls"])
    span_run = subprocess.run(["bash", "tools/run_python_project_data.sh", PREFIX + "span-review.py"],
                              cwd=ROOT, capture_output=True, text=True)
    require(span_run.returncode == 0 and span_run.stderr == "", "span supplemental review exit: " + span_run.stderr)
    span = json.loads(read(PREFIX + "span-verification.json"))
    require(json.loads(span_run.stdout) == span and span["result"] == "PASS", "span supplemental review identity")
    for path, expected in span["tracked_inputs"].items():
        require(sha(read(path)) == expected, "span supplemental input identity: " + path)
    counts["t/actionir_nested_block_source_spans.t"] = span["top_level_TAP_tests"]
    controls.extend(span["controls"])
    compatibility_run = subprocess.run(["bash", "tools/run_python_project_data.sh", PREFIX + "compatibility-review.py"],
                                       cwd=ROOT, capture_output=True, text=True)
    require(compatibility_run.returncode == 0 and compatibility_run.stderr == "", "compatibility supplemental review exit: " + compatibility_run.stderr)
    compatibility = json.loads(read(PREFIX + "compatibility-verification.json"))
    require(json.loads(compatibility_run.stdout) == compatibility and compatibility["result"] == "PASS", "compatibility supplemental review identity")
    for path, expected in compatibility["tracked_inputs"].items():
        require(sha(read(path)) == expected, "compatibility supplemental input identity: " + path)
    counts["t/actionir_raw_dependency_compatibility.t"] = compatibility["top_level_TAP_tests"]
    controls.extend(compatibility["controls"])
    envelope_spec = importlib.util.spec_from_file_location("initial_span_envelopes", ROOT / (PREFIX + "span-initial-envelope.py"))
    envelope_module = importlib.util.module_from_spec(envelope_spec)
    envelope_spec.loader.exec_module(envelope_module)
    original_hashes = json.loads(read(PREFIX + "pre-compat-verification.json"))["tracked_inputs"]
    for name in ("span-initial.json", "span-unit-initial.log"):
        raw = envelope_module.validate(json.loads(read(PREFIX + name)))
        require(sha(raw) == original_hashes[PREFIX + name], "initial diagnostic byte-exact preservation")
    interrupted = json.loads(read(PREFIX + "canonical-interrupted.json"))
    interrupted_raw = envelope_module.validate(interrupted)
    require(interrupted["kind"] == "interrupted_canonical_startup" and interrupted["exit"] == 143
            and interrupted["activation"] == BASE and len(interrupted["staged_content_sha256"]) == 64
            and b"running the general doctrine enforcer" in interrupted_raw,
            "interrupted canonical limits")
    paths = set(subprocess.check_output(["git", "ls-tree", "-r", "--name-only", BASE,
                                        "--", "perl", "specs"], cwd=ROOT, text=True).splitlines())
    current_inventory = set(subprocess.check_output(["git", "ls-files", "perl", "specs"],
                                                    cwd=ROOT, text=True).splitlines())
    require(current_inventory == paths | {"perl/LinkedSpec/ActionIR/RawDependencies.pm"},
            "declared Perl/spec source inventory")
    changed = {"perl/LinkedSpec/RuleIR/EmitContext.pm", "perl/LinkedSpec/ActionIR/Diagnostics.pm",
               "perl/LinkedSpec/ActionIR/AST/Parser.pm", "perl/LinkedSpec/RuleIR.pm"}
    for path in paths - changed:
        require(read(path) == subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT),
                "unchanged executable input: " + path)
    for owner, path in (("EmitContext", "perl/LinkedSpec/RuleIR/EmitContext.pm"),
                        ("Diagnostics", "perl/LinkedSpec/ActionIR/Diagnostics.pm")):
        raw = read(PREFIX + "before-" + owner + ".pm")
        require(raw == subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT)
                and old_record["baseline_owners"][owner] == new_record["baseline_owners"][owner] == sha(raw),
                "exact baseline owner identity")
    paths.update(TESTS)
    paths.update(keyword["tracked_inputs"])
    paths.update(span["tracked_inputs"])
    paths.update(compatibility["tracked_inputs"])
    for path in set(TESTS) - {"t/actionir_raw_dependency_metadata.t", "t/actionir_raw_dependency_provenance.t"}:
        require(read(path) == subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT),
                "unchanged direct-dependent test source: " + path)
    paths.update(("perl/LinkedSpec/ActionIR/RawDependencies.pm", "tools/run_python_project_data.sh",
                  "tools/project_data_run.sh", "tools/project_data_env.sh",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm"))
    paths.update((historical_prefix + "cases.json", historical_prefix + "observations.json"))
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / "docs/checkpoints").glob(OWNER + "-*")
                 if path.name not in {OWNER + "-verification.json", OWNER + "-book-check.py",
                                      OWNER + "-book-check.json", OWNER + "-claim.py",
                                      OWNER + "-governance-check.json"})
    print(json.dumps({"owner": OWNER, "result": "PASS", "activation": BASE,
                      "full_sources": len(cases), "native_fresh_pairs": len(new),
                      "census_sources": len(a), "shipped_sources": 22, "rewrite_units": units_count,
                      "raw_AST_marker_counts": marker_counts, "historical_original_pairs": len(historical["rows"]),
                      "first_canonical_failure_log_bytes": len(failure_raw),
                      "supplemental_keyword_sources": keyword["sources"],
                      "supplemental_keyword_native_fresh_pairs": keyword["native_fresh_pairs"],
                      "second_canonical_failure_log_bytes": keyword["second_canonical_failure_log_bytes"],
                      "supplemental_span_sources": span["sources"],
                      "supplemental_span_native_fresh_pairs": span["native_fresh_pairs"],
                      "third_canonical_failure_log_bytes": span["third_canonical_failure_log_bytes"],
                      "supplemental_compatibility_sources": compatibility["sources"],
                      "scoped_Phase0_subtests": compatibility["scoped_Phase0_subtests"],
                      "changed_Phase0_assertions": compatibility["changed_Phase0_assertions"],
                      "source_results": results, "actual_RED": reds, "tests": counts,
                      "top_level_TAP_tests": sum(counts.values()), "controls": controls,
                      "tracked_inputs": {path:sha(read(path)) for path in sorted(paths)},
                      "limits": "Rule-action/deferred source-unit telemetry only. Event diagnostics, AST structure/source/values, routed values and original error identities are retained. Three nested child frames now preserve authored offsets; substitution/dump/emitted bytes may differ only inside structurally verified serialized AST coordinates. Exact generated lifecycle slot/source ownership suppresses added expression scanning, while original fallback events/counts remain intact. Sanctioned exact legacy whole statements retain canonical ownership; bare payloads and ordinary typed assignment groups expose genuine inner raw operands. Deferred raw groups are preserved. Fourteen measured metadata assertions change in five Phase0 fixtures; exact normalization recovers all prior source/runtime oracles. Final primary/census records are fresh at frozen final production; the unmasked metadata replay is diagnostic only. Raw streams remain complete; stderr/timestamps are not projected or asserted byte-equal across runs. Six infix host results/warnings and an unsupported deferred-body failure are not portable positives. Function/transitive guards keep their measured unresolved behavior. All22 shipped sources have zero raw AST markers, so covered shipped-raw observations are vacuous. Quoted helpers and comments remain independently owned defects. Three fixed seeds are named observations, not a probability interval. No new grammar, runtime semantics, function admission, dispatcher/full execution or other backend admission."}, indent=2))


if __name__ == "__main__":
    main()
