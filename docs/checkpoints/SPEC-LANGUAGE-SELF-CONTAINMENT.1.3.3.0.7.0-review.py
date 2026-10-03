"""Read-only review of bounded public raw-readiness diagnosis and actual controls."""
import copy
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0"
PREFIX = "docs/checkpoints/" + OWNER + "-"
BASE = "834e0a3ddaf63789ea23dfac6c7cf273c01342e6"
NESTED = ("assignment_raw", "condition_raw", "while_raw", "call_argument_raw",
          "array_element_raw", "hash_value_raw", "codeblock_body_raw")
VALUES = {"assignment_raw": 1, "condition_raw": "yes", "while_raw": "yes",
          "call_argument_raw": 3, "array_element_raw": [1], "hash_value_raw": {"n": 1},
          "codeblock_body_raw": None, "assignment_canonical": 3,
          "condition_canonical": "no", "call_argument_canonical": 5,
          "container_canonical": [3, {"n": 2}], "codeblock_canonical": "ok",
          "literal_data": "i=i+1; i < 1", "comment_data": "ok",
          "quoted_helper_known": "return(inner); if(true)", "raw_statement": 3}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read(path):
    candidate = Path(path)
    require(not candidate.is_absolute() and ".." not in candidate.parts, "relative input")
    resolved = (ROOT / candidate).resolve()
    resolved.relative_to(ROOT)
    return resolved.read_bytes()


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def raw_nodes(value, path=""):
    rows = []
    if isinstance(value, dict):
        if value.get("kind") == "raw_perl":
            rows.append({"path": path, "node": value})
        for key, child in value.items():
            rows.extend(raw_nodes(child, path + "/" + key))
    elif isinstance(value, list):
        for index, child in enumerate(value):
            rows.extend(raw_nodes(child, path + "/" + str(index)))
    return rows


def occurrences(rows, action):
    unique = {}
    for row in rows:
        node = row["node"]
        span = node["source_span"]
        start, end = span["start"], span["end"]
        require(isinstance(start, int) and isinstance(end, int) and
                0 <= start < end <= len(action) and action[start:end] == node["source"],
                "raw source span")
        require(node["reason"] == "unsupported_expression", "raw reason")
        key = (start, end, node["source"], node["reason"])
        unique.setdefault(key, []).append(row["path"])
    return [{"start": key[0], "end": key[1], "source": key[2], "reason": key[3],
             "representations": paths} for key, paths in sorted(unique.items())]


def check_observations(record, cases):
    require(record["owner"] == OWNER and record["seeds"] == ["0", "1", "2"] and
            record["perturbation"] == "2", "capture population")
    require(set(cases) == set(VALUES), "source membership")
    found, summaries = {}, []
    for row in record["rows"]:
        require(row["exit"] == 0 and row["stderr"] == "", "public producer exit")
        require(json.loads(row["stdout"]) == row["observation"], "raw public stdout")
        require(len(row["observation"]["cases"]) == 1, "one actual source per process")
        case = row["observation"]["cases"][0]
        name, seed = case["id"], case["seed"]
        require(name in cases and seed in record["seeds"] and (name, seed) not in found,
                "case/seed membership")
        require(row["command"] == ["perl", "-Iperl", PREFIX + "probe.pl", name],
                "actual public command")
        require(case["source"] == cases[name]["source"] and
                case["source_sha256"] == digest(case["source"].encode()), "source identity")
        action = re.search(r"\bI\s*\{(.*)\}\s*$", case["source"], re.S).group(1)
        require(case["action_probe_source"] == "{" + action + "}" and
                case["ast"]["source"] == action, "exact public action AST source")
        rows = raw_nodes(case["ast"])
        unique = occurrences(rows, action)
        expected = cases[name]["expected_raw_expression_sources"]
        if name == "comment_data":
            require(expected == [], "independent comment data oracle")
            expected = ["# i=i+1; i < 1"]  # observed defect, not the desired oracle
        elif name == "raw_statement":
            require(expected is None, "legacy control policy boundary")
            expected = ["my $host=3", "$host"]
        require([item["source"] for item in unique] == expected, "current raw AST sources")
        if name in ("condition_raw", "while_raw"):
            control = case["ast"]["statements"][1]["expr"]
            require(control["condition"] == control["args"][0] and len(rows) == 2 and
                    len(unique) == 1, "serialized control condition aliases")
        meta = case["metadata"]
        actual = tuple(meta[key] for key in ("language_agnostic_action_ir_ready",
                       "raw_perl_dependency_count", "canonical_action_ir_fallback_count",
                       "unresolved_helper_count"))
        expected_flags = (0, 0, 0, 3) if name == "quoted_helper_known" else \
                         (0, 1, 1, 0) if name in ("comment_data", "raw_statement") else (1, 0, 0, 0)
        require(actual == expected_flags, "current readiness tuple")
        if name in NESTED:
            require(len(unique) == 1 and meta["raw_perl_dependency_statements"] == [] and
                    meta["language_agnostic_action_ir_blocker_statements"] == [],
                    "actual missed nested blocker")
        require(case["native"]["value"] == case["fresh"]["value"] == VALUES[name],
                "current observed value")
        require(case["fresh"]["stdout"] == "", "quiet fresh execution")
        if name != "codeblock_body_raw":
            require(case["native"]["stdout"] == "", "quiet native execution")
        require(case["fresh"]["emitted_sha256"] == case["emitted_sha256"] ==
                digest(case["emitted"].encode()), "fresh emitted identity")
        require(case["substitution_sha256"] == digest(case["substitution"].encode()),
                "substitution identity")
        if name == "codeblock_body_raw":
            native = case["native"]["context_error"]
            fresh = case["fresh"]["exception"]
            require(native["type"] == "runtime_handler" and fresh["type"] == "generated_source_error"
                    and native["detail"] == fresh["detail"] and
                    native["detail"]["code"] == "unsupported_codeblock_actionir" and
                    native["detail"]["kind"] == "raw_perl" and
                    case["native"]["actual_error_identity"] == case["fresh"]["actual_error_identity"] == 1,
                    "actual deferred raw failure and identity")
            # SpecEntry reports failed handler evaluation at DUMP_NONE. Keep the
            # original timestamps and full stream; only validate its two records.
            lines = case["native"]["stdout"].splitlines()
            prefix = r"\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]\[NONE\]\[SpecEntry\.pm\]\[trace_decision:63\] "
            require(len(lines) == 2 and
                    re.fullmatch(prefix + r"DECISION rule_handler_eval:Top => SKIPPED", lines[0]) and
                    re.fullmatch(prefix + r"  Context: bless\( \{'code' => 'unsupported_codeblock_actionir','kind' => 'raw_perl'\}, 'LinkedSpec::CodeblockRuntime::Error' \)", lines[1]) and
                    case["native"]["stderr"] == case["fresh"]["stderr"] == "",
                    "actual retained deferred failure trace")
        else:
            require(case["native"]["exception"] is None and
                    case["native"]["context_error"] is None and case["fresh"]["exception"] is None,
                    "actual healthy route")
        if name in NESTED and name != "codeblock_body_raw":
            require('Unquoted string "i"' in case["fresh"]["stderr"] and
                    'Argument "i" isn\'t numeric' in case["fresh"]["stderr"],
                    "actual retained host warnings")
        found[(name, seed)] = case
        summaries.append({"id": name, "seed": seed, "raw_representations": len(rows),
                          "raw_source_occurrences": unique, "current_flags": list(actual),
                          "native_value": case["native"]["value"],
                          "fresh_warning_bytes": len(case["fresh"]["stderr"].encode())})
    require(set(found) == {(name, seed) for name in cases for seed in record["seeds"]},
            "complete current population")
    for name in cases:
        baseline = found[(name, "0")]
        for seed in ("1", "2"):
            other = found[(name, seed)]
            for field in ("ast", "metadata", "substitution", "dump", "emitted"):
                require(other[field] == baseline[field], "actual seed stability: " + field)
    return found, summaries


def check_aliases(record, cases):
    require([row["id"] for row in record["aliases"]] == ["condition_raw", "while_raw"],
            "control alias population")
    for row in record["aliases"]:
        require(row["source"] == cases[row["id"]]["source"] and row["shared_reference"] == 1
                and row["condition"] == row["argument"], "control shared condition identity")
        occurrences([{"path": "condition", "node": row["condition"]}], row["action"])
    require(record["repeated_source"] == "i=i+1; i=i+1" and
            record["repeated_distinct_references"] == 1, "repeated source identity")
    rows = [{"path": str(index), "node": node} for index, node in enumerate(record["repeated_raw"])]
    unique = occurrences(rows, record["repeated_source"])
    require(len(rows) == len(unique) == 2 and
            [(row["start"], row["end"]) for row in unique] ==
            [(match.start(), match.end()) for match in re.finditer(r"i\+1", record["repeated_source"])],
            "distinct repeated source occurrences")
    return {"actual_shared_control_references": 2, "repeated_distinct_source_occurrences": 2,
            "supplemental_scope": "one AST-only repeated-action fragment; two existing source ASTs"}


def check_traces(record, cases, observations):
    require(record["owner"] == OWNER and record["seed"] == "0" and
            len(record["rows"]) == len(cases), "trace population")
    found = set()
    for row in record["rows"]:
        require(row["exit"] == 0 and row["stderr"] == "" and
                json.loads(row["stdout"]) == row["observation"], "actual trace output")
        observation = row["observation"]
        name = observation["id"]
        require(name in cases and name not in found and observation["source"] == cases[name]["source"]
                and observation["substitution"] == observations[(name, "0")]["substitution"],
                "source-bound trace substitution")
        require(row["command"] == ["perl", "-Iperl", PREFIX + "trace.pl", name],
                "actual trace command")
        if name == "assignment_raw":
            require("passthrough_no_call => TAKEN" in observation["trace"] and
                    "flow_composite_value => TAKEN" in observation["trace"] and
                    "canonical_raw_perl_fallback => SKIPPED" in observation["trace"],
                    "reached raw passthrough branch")
        found.add(name)
    require(found == set(cases), "complete trace sources")


def check_tests(record):
    expected = {"t/actionir_ast_parser.t": 23, "t/noncurrent_helper_metadata.t": 2,
                "t/generated_source_contract.t": 12, "t/trace_actionir_pipeline.t": 5}
    found = {}
    for row in record["rows"]:
        name = row["command"][-1]
        require(name in expected and name not in found and row["exit"] == 0, "TAP exit/membership")
        plans = re.findall(r"^1\.\.(\d+)$", row["stdout"], re.M)
        count = re.search(r"Files=1, Tests=(\d+)", row["stdout"])
        require(plans == [str(expected[name])] and count and int(count.group(1)) == expected[name]
                and "All tests successful." in row["stdout"] and "Result: PASS" in row["stdout"],
                "complete TAP plan/result")
        found[name] = expected[name]
    require(found == expected, "complete test selection")
    return found


def rejected(name, action, reason):
    try:
        action()
    except ValueError as error:
        require(str(error) == reason, "unrelated control rejection: " + name + ": " + str(error))
        return {"name": name, "reason": str(error)}
    raise ValueError("control accepted: " + name)


def changed_case(record, name, mutate):
    row = next(row for row in record["rows"] if row["observation"]["cases"][0]["id"] == name)
    mutate(row["observation"]["cases"][0])
    row["stdout"] = json.dumps(row["observation"])


def main():
    cases = {row["id"]: row for row in json.loads(read(PREFIX + "cases.json"))}
    observations = json.loads(read(PREFIX + "observations.json"))
    aliases = json.loads(read(PREFIX + "ast-alias.json"))
    traces = json.loads(read(PREFIX + "trace.json"))
    tests = json.loads(read(PREFIX + "tests.json"))
    found, summaries = check_observations(observations, cases)
    alias_report = check_aliases(aliases, cases)
    check_traces(traces, cases, found)
    counts = check_tests(tests)
    controls = []
    mutations = (
        ("readiness hidden", "assignment_raw", lambda c: c["metadata"].update(language_agnostic_action_ir_ready=0), "current readiness tuple"),
        ("raw child erased", "assignment_raw", lambda c: c["ast"]["statements"][1]["expr"]["value"].update(kind="literal"), "current raw AST sources"),
        ("raw span shifted", "assignment_raw", lambda c: c["ast"]["statements"][1]["expr"]["value"]["source_span"].update(start=9), "raw source span"),
        ("source replaced", "assignment_raw", lambda c: c.update(source="Top:: I { return(9) }"), "source identity"),
        ("fresh input replaced", "assignment_raw", lambda c: c["fresh"].update(emitted_sha256="0" * 64), "fresh emitted identity"),
        ("canonical value wrong", "assignment_canonical", lambda c: c["fresh"].update(value=4), "current observed value"),
        ("host warnings lost", "assignment_raw", lambda c: c["fresh"].update(stderr=""), "actual retained host warnings"),
        ("deferred failure trace lost", "codeblock_body_raw", lambda c: c["native"].update(stdout=""), "actual retained deferred failure trace"),
    )
    for name, target, mutate, reason in mutations:
        altered = copy.deepcopy(observations)
        changed_case(altered, target, mutate)
        controls.append(rejected(name, lambda: check_observations(altered, cases), reason))
    altered = copy.deepcopy(aliases)
    altered["aliases"][0]["shared_reference"] = 0
    controls.append(rejected("shared condition hidden", lambda: check_aliases(altered, cases), "control shared condition identity"))
    altered = copy.deepcopy(aliases)
    altered["repeated_raw"][1]["source_span"] = copy.deepcopy(altered["repeated_raw"][0]["source_span"])
    controls.append(rejected("repeated occurrence collapsed", lambda: check_aliases(altered, cases), "distinct repeated source occurrences"))
    altered = copy.deepcopy(tests)
    altered["rows"][0]["exit"] = 1
    controls.append(rejected("failed TAP hidden", lambda: check_tests(altered), "TAP exit/membership"))
    altered = copy.deepcopy(traces)
    row = next(row for row in altered["rows"] if row["observation"]["id"] == "assignment_raw")
    row["observation"]["trace"] = row["observation"]["trace"].replace("passthrough_no_call => TAKEN", "removed")
    row["stdout"] = json.dumps(row["observation"])
    controls.append(rejected("reached branch removed", lambda: check_traces(altered, cases, found), "reached raw passthrough branch"))
    paths = set(subprocess.check_output(["git", "ls-files", "perl", "specs"], cwd=ROOT, text=True).splitlines())
    paths.update(counts)
    paths.update(("tools/run_python_project_data.sh", "tools/project_data_run.sh", "tools/project_data_env.sh",
                  "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm"))
    for path in paths:
        require(read(path) == subprocess.check_output(["git", "show", BASE + ":" + path], cwd=ROOT),
                "unchanged executable input: " + path)
    paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / "docs/checkpoints").glob(OWNER + "-*")
                 if path.name not in (OWNER + "-verification.json", OWNER + "-book-check.py", OWNER + "-book-check.json"))
    print(json.dumps({"owner": OWNER, "result": "PASS", "activation": BASE,
                      "full_sources": len(cases), "case_seed_native_fresh_pairs": len(found),
                      "missed_nested_sources": list(NESTED), "missed_nested_case_seed_pairs": len(NESTED) * 3,
                      "comments_false_raw_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.3",
                      "quoted_false_helper_owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2",
                      "source_results": summaries, "alias_proof": alias_report, "traces": len(traces["rows"]),
                      "tests": counts, "top_level_TAP_tests": sum(counts.values()), "controls": controls,
                      "tracked_inputs": {path: digest(read(path)) for path in sorted(paths)},
                      "limits": "Current source-bound diagnosis, not a runtime/schema repair. Six infix host results/warnings and a deferred typed failure are not portable positives. Desired comment data oracle intentionally fails current AST classification. Condition aliases are two representations of one source occurrence; repeated equal-text distinct spans stay distinct. Three fixed seeds are named observations, not a probability interval. Raw streams are preserved; no warning/time projection or equality assertion for stderr. One supplemental AST-only fragment has no added native/fresh route. No function-body/shipped-spec census, arbitrary syntax, infix admission, dispatcher/full composition or other-backend promotion."}, indent=2))


if __name__ == "__main__":
    main()
